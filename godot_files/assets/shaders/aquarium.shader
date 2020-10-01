shader_type spatial;

render_mode specular_toon;
render_mode ambient_light_disabled; // disable reflection of skymap
render_mode diffuse_lambert_wrap;

uniform vec4 water_color : hint_color;

uniform sampler2D worley_noise;

uniform sampler2D z_tex;

uniform sampler2D vertex_position_tex;
uniform sampler2D n1;
uniform sampler2D n2;
uniform sampler2D n3;
uniform sampler2D n4;
uniform sampler2D n5;
uniform sampler2D n6;

uniform float num_vertices = 642.0f;

varying vec3 vertex_pos; // used to access vertex positions from fragment shader

/* Sample triplanar texture. */
vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp=vec4(0.0);
	samp+= texture(p_sampler,p_triplanar_pos.xy) * p_weights.z;
	samp+= texture(p_sampler,p_triplanar_pos.xz) * p_weights.y;
	samp+= texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}

/* Return UV of neighbouring vertex. */
vec2 getNeighbour(sampler2D n, vec2 uv) {
	vec4 c = texture(n, uv);
	if (c.a == 0.0f) {
		return vec2(-1.0f);
	}
	/* idx = (c.r * 255) << 16 + (c.r * 255) << 8 + c.b * 255 */
	float idx = c.r * 65280f + c.g * 255.0;
	return vec2((idx + 0.5) / num_vertices, 0.0f);
}

/* Return displacement of vertex at uv. */
float getDisplacement(vec2 uv) {
	vec4 c = texture(z_tex, uv);
	return c.r - c.g;
}

/* Return vertex position of vertex at uv. */
vec3 getPos(vec2 uv) {
	return texture(vertex_position_tex, uv).xyz * 2.0f - 1.0f;
}

/* Calculate face normal from vertex positions. */
vec3 calculateFaceNormal(vec3 a, vec3 b, vec3 c) {
	vec3 n = cross(b - a, c - a);
	vec3 v = a + b + c;
	if (dot(v, n) < 0.0f) {
		n = -n;
	}
	return n;
}

/* Calculate vertex normal as average of all adjacent face normals. */
vec3 calculateVertexNormal(vec2 uv, vec3 v) {
	vec2 uv1 = getNeighbour(n1, uv);
	vec2 uv2 = getNeighbour(n2, uv);
	vec2 uv3 = getNeighbour(n3, uv);
	vec2 uv4 = getNeighbour(n4, uv);
	vec2 uv5 = getNeighbour(n5, uv);
	vec2 uv6 = getNeighbour(n6, uv);
	
	vec3 p1 = getPos(uv1);
	vec3 p2 = getPos(uv2);
	vec3 p3 = getPos(uv3);
	vec3 p4 = getPos(uv4);
	vec3 p5 = getPos(uv5);
	
	vec3 q1 = p1 + normalize(p1) * getDisplacement(uv1);
	vec3 q2 = p2 + normalize(p2) * getDisplacement(uv2);
	vec3 q3 = p3 + normalize(p3) * getDisplacement(uv3);
	vec3 q4 = p4 + normalize(p4) * getDisplacement(uv4);
	vec3 q5 = p5 + normalize(p5) * getDisplacement(uv5);

	vec3 f1 = calculateFaceNormal(v, q1, q2);
	vec3 f2 = calculateFaceNormal(v, q2, q3);
	vec3 f3 = calculateFaceNormal(v, q3, q4);
	vec3 f4 = calculateFaceNormal(v, q4, q5);
	vec3 f5 = vec3(0.0f);
	vec3 f6 = vec3(0.0f);
	if (uv6 == vec2(-1.0f)) { // vertex has 5 neighbours
		f5 = calculateFaceNormal(v, q5, q1);
	} else { // vertex has 6 neighbours
		vec3 p6 = getPos(uv6);
		vec3 q6 = p6 + normalize(p6) * getDisplacement(uv6);
		f5 = calculateFaceNormal(v, q5, q6);
		f6 = calculateFaceNormal(v, q6, q1);	
	}
	
	vec3 n = vec3(0.0f);
	
	n += f1.xyz;
	n += f2.xyz;
	n += f3.xyz;
	n += f4.xyz;
	n += f5.xyz;
	n += f6.xyz;
	
	return normalize(n);
}

void vertex() {
	/* Displace vertex and calculate new normal. */
	VERTEX += normalize(VERTEX) * getDisplacement(UV);
	NORMAL = calculateVertexNormal(UV, VERTEX);
	vertex_pos = VERTEX;
}

void fragment() {
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	METALLIC = 0.0f;
	ROUGHNESS = 0.01f * (1.0 - fresnel);
	
	/* Diffraction based on normals and worley noise. */
	vec2 diffr = - 0.02f * NORMAL.xy;
	diffr += 0.005f * triplanar_texture(worley_noise, NORMAL, vertex_pos + 0.05f*TIME).rg
					* triplanar_texture(worley_noise, NORMAL, vertex_pos - 0.05f*TIME).rg;

	ALBEDO = mix(texture(SCREEN_TEXTURE, SCREEN_UV + diffr).rgb, water_color.rgb, water_color.a);
}

void light() {
	DIFFUSE_LIGHT = ALBEDO;
	
	/* Modify width of rim lighting based on worley noise. */
	float rim_width = 4.0f + triplanar_texture(worley_noise, NORMAL, vertex_pos + 0.05f*TIME).r
							 * triplanar_texture(worley_noise, NORMAL, vertex_pos - 0.05f*TIME).r
							 * 12.0f;
	
	/* Rim lighting taken from Godot source. */
	float NdotV = dot(NORMAL, VIEW);
	float cNdotV = max(abs(NdotV), 1e-6);
	float rim = 0.2f;
	float rim_tint = 1.0f;
	vec3 diffuse_color = vec3(1.0f);
	float rim_light = pow(max(0.0, 1.0 - cNdotV), max(0.0, (1.0 - ROUGHNESS) * rim_width));
	DIFFUSE_LIGHT += rim_light * rim * mix(vec3(1.0), diffuse_color, rim_tint) * LIGHT_COLOR;
	
	/* Specular toon taken from Godot source. */
	vec3 R = normalize(-reflect(LIGHT, NORMAL));
	float RdotV = dot(R, VIEW);
	float mid = 1.0 - ROUGHNESS;
	mid *= mid;
	SPECULAR_LIGHT = ATTENUATION * smoothstep(mid - ROUGHNESS * 0.5, mid + ROUGHNESS * 0.5, RdotV) * mid;
}