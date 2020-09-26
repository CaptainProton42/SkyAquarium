extends Viewport

onready var simulation_material = get_node("ColorRect").material

func _initialize():
	var img = Image.new()
	if ProjectSettings.get_setting("rendering/quality/driver/driver_name") == "GLES3":
		img.create(642, 2, false, Image.FORMAT_RGBA8)
	else:
		img.create(642, 2, false, Image.FORMAT_RGB8)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	tex.flags = 0

	simulation_material.set_shader_param("u", tex)
	simulation_material.set_shader_param("v", tex.duplicate())

func _update_map():
	var img = get_texture().get_data()
	simulation_material.get_shader_param("v").set_data(simulation_material.get_shader_param("u").get_data())
	simulation_material.get_shader_param("u").set_data(img)

var lock = false
func _update():
	if not lock:
		lock = true
		_update_map()
		render_target_update_mode = UPDATE_ONCE
		
		yield(get_tree(), "idle_frame")
		lock = false

func _physics_process(_delta):
	_update()

func _ready():
	_initialize()
	render_target_update_mode = UPDATE_ONCE

func _on_ClickArea_input_event(_camera, event, click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			simulation_material.set_shader_param("click_position", Quat(click_position.x, click_position.y, click_position.z, 0.5))
			yield(get_tree().create_timer(0.1), "timeout")
			simulation_material.set_shader_param("click_position", Quat(click_position.x, click_position.y, click_position.z, -0.5))
			yield(get_tree().create_timer(0.1), "timeout")
			simulation_material.set_shader_param("click_position", Color(99.0, 99.0, 99.0, 0.0))
