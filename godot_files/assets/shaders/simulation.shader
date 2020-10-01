shader_type canvas_item;

uniform float a = 0.1f;

uniform vec4 click_position;

uniform sampler2D vertex_pos_tex;

uniform sampler2D z_tex;
uniform sampler2D z_old_tex;

uniform sampler2D n1;
uniform sampler2D n2;
uniform sampler2D n3;
uniform sampler2D n4;
uniform sampler2D n5;
uniform sampler2D n6;

uniform float num_vertices = 642.0f;

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

/* Return vertex position of vertex at uv. */
vec3 getPos(vec2 uv) {
	return texture(vertex_pos_tex, uv).xyz * 2.0f - 1.0f;
}

void fragment() {
	vec2 uv1 = getNeighbour(n1, UV);
	vec2 uv2 = getNeighbour(n2, UV);
	vec2 uv3 = getNeighbour(n3, UV);
	vec2 uv4 = getNeighbour(n4, UV);
	vec2 uv5 = getNeighbour(n5, UV);
	vec2 uv6 = getNeighbour(n6, UV);
	
	float num_n = 5.0f;
	vec2 sum_z = vec2(0.0f);
	sum_z += texture(z_tex, uv1).rg;
	sum_z += texture(z_tex, uv2).rg;
	sum_z += texture(z_tex, uv3).rg;
	sum_z += texture(z_tex, uv4).rg;
	sum_z += texture(z_tex, uv5).rg;

	if (uv6 != vec2(-1.0f)) {
		sum_z += texture(z_tex, uv6).rg;
		num_n++;
	}
	
	vec2 z = texture(z_tex, UV).rg;
	vec2 z_old = texture(z_old_tex, UV).rg;
	
	COLOR.rg = a * sum_z / num_n + (2.0f - a) * z - z_old;
	
	/* Displace based on distance to mouse click. */
	float click_dist = length(click_position.xyz - getPos(UV));
	if (click_dist < 0.15f) {
		if (click_position.a > 0.0f) {
			COLOR.r = (0.15f - click_dist) / 0.15f * click_position.w;
		} else {
			COLOR.g = (0.15f - click_dist) / 0.15f * -click_position.w;
		}
	}
}