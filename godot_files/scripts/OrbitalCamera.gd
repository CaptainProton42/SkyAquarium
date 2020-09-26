# Camera that can be rotated around a pivot by dragging the mouse. */

extends Spatial

export var input_ray_length = 10000
export var grab_force = 50.0
export var grab_dampening = 15.0

var grabbed_object : Node = null

export var speed = 0.005
export var limit_up_down = Vector2(-15.0, 15.0)

onready var pivot = get_node("Pivot")
onready var camera = pivot.get_node("Camera")

var drag_orig
var rot_orig
var dragging = false

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			drag_orig = camera.get_viewport().get_mouse_position()
			rot_orig = pivot.rotation
			dragging = true
		else:
			dragging = false

func _process(_delta):
	if dragging:
		pivot.rotation.y = rot_orig.y-speed*(camera.get_viewport().get_mouse_position() - drag_orig).x
		pivot.rotation.x = clamp(rot_orig.x-speed*(camera.get_viewport().get_mouse_position() - drag_orig).y, limit_up_down.x / 180.0 * PI, limit_up_down.y / 180.0 * PI)
