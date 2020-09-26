# Simple CPU boids based on an implementation by Sebastian Lague:
# https://github.com/SebLague/Boids

extends Spatial

var velocity : Vector3 = Vector3(1.0, 0.0, 0.0)
var direction : Vector3
var acceleration : Vector3

export var ray_length : float = 0.2
export var min_speed : float = 0.1
export var max_speed : float = 0.2

var obstacle_avoid_weight : float = 1.0
var cohesion_weight : float = 1.0
var align_weight : float = 1.0
var separation_weight : float = 1.0
var attention_weight : float = 1.0

var flock_count : int
var flock_centre : Vector3
var flock_direction : Vector3
var separation_heading : Vector3
var attention_heading : Vector3

func cast_ray(ray_direction : Vector3):
	var from : Vector3 = global_transform.origin
	var to : Vector3 = from + ray_length * ray_direction

	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(to, from, [], 2147483647, true, false)

	return result

# Returns opposite direction of the first ray that hits an obstacle or the forward
# direction if no ray collided (both in global space)
func get_avoid_direction_or_forward() -> Vector3:
	# Check if near the water surface
	if translation.length() > 1.0 - ray_length:
		return -translation.normalized()

	# Check for obstacles
	var directions : PoolVector3Array = BoidHelper.directions
	for d in directions:
		var res = cast_ray(d)
		if res:
			return -d
	return global_transform.basis.x

func update(delta):
	var avoid_dir : Vector3 = get_avoid_direction_or_forward()
	var obstacle_avoid_force : Vector3 = obstacle_avoid_weight * steer_towards(avoid_dir)
	var attention_force : Vector3 = attention_weight * steer_towards(attention_heading)

	acceleration += obstacle_avoid_force
	acceleration += attention_force

	if flock_count > 0:
		var cohesion_force : Vector3 = cohesion_weight * steer_towards(flock_centre - translation)
		var align_force : Vector3 = align_weight * steer_towards(flock_direction)
		var separation_force : Vector3 = separation_weight * steer_towards(separation_heading)
		acceleration += cohesion_force
		acceleration += align_force
		acceleration += separation_force

	# Integrate forces
	var old_velocity : Vector3 = velocity
	velocity += delta * acceleration

	direction = velocity.normalized()
	var speed : float = velocity.length()
	
	speed = clamp(speed, min_speed, max_speed)
	velocity = direction * speed

	translation += delta * velocity

	# Rotate the fish around an axis perpendicular to the velocity change	
	var angle : float = old_velocity.angle_to(velocity)
	var axis : Vector3 = old_velocity.cross(velocity).normalized()
	if axis.is_normalized():
		global_transform.basis = global_transform.basis.rotated(axis, angle)

func steer_towards(dir : Vector3) -> Vector3:
	return max_speed * dir.normalized() - velocity

func set_palette(colors : Array):
	get_node("Torso").get_surface_material(0).set_shader_param("color", colors[0])
	get_node("Torso").get_surface_material(0).set_shader_param("fin_color", colors[1])
	get_node("Mouth").get_surface_material(0).albedo_color = colors[1]
