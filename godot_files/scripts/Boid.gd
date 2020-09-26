# Simple CPU boids based on an implementation by Sebastian Lague:
# https://github.com/SebLague/Boids

extends Spatial

export var boid_size : int = 5
export var min_speed : float = 0.3
export var max_speed : float = 0.6
export var perception_radius : float = 1.0
export var avoidance_radius : float = 0.4

export var obstacle_avoid_weight : float = 1.0
export var cohesion_weight : float = 1.0
export var align_weight : float = 1.0
export var separation_weight : float = 1.0
export var attention_weight : float = 1.0

export var attention_span : float = 0.5

onready var fish_scene : PackedScene = preload("res://scenes//Fish.tscn")

var point_of_interest : Vector3

var attention_timer : float = 0.0

func _ready():
	for _i in range(boid_size):
		var child = fish_scene.instance()
		child.min_speed = min_speed
		child.max_speed = max_speed
		child.ray_length = avoidance_radius
		child.obstacle_avoid_weight = obstacle_avoid_weight
		child.cohesion_weight = cohesion_weight
		child.align_weight = align_weight
		child.separation_weight = separation_weight
		child.attention_weight = attention_weight
		add_child(child)

		child.translation = Vector3(randf(), randf(), randf()) * 0.5
		var i = randi() % BoidHelper.palettes.size()
		child.set_palette(BoidHelper.palettes[i])

func _physics_process(delta):
	for child in get_children():
		child.flock_centre = Vector3(0.0, 0.0, 0.0)
		child.flock_direction = Vector3(0.0, 0.0, 0.0)
		child.separation_heading = Vector3(0.0, 0.0, 0.0)
		child.attention_heading = child.direction
		child.flock_count = 0
		for flockmate in get_children():
			if child != flockmate:
				var offset : Vector3 = flockmate.translation - child.translation
				var distance : float = offset.length()

				if distance < perception_radius:
					child.flock_count += 1
					child.flock_centre += flockmate.translation
					child.flock_direction += flockmate.direction
					if distance < avoidance_radius and distance > 0.0:
						child.separation_heading -= offset / distance

		if attention_timer > 0.0:
			child.attention_heading = (point_of_interest - child.translation).normalized()
			attention_timer -= delta

		if (child.flock_count > 0):
			child.flock_centre /= child.flock_count

		child.update(delta)

func alert_boid(position : Vector3):
	attention_timer = attention_span
	point_of_interest = position

func _on_ClickArea_input_event(_camera, event, click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			alert_boid(click_position)