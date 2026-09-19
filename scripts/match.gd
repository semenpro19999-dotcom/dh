extends Node3D
## KS3 — локальный 3D tactical slice.
## WASD — движение, мышь — обзор и огонь, Esc — выход в командный центр.

const C_BG := Color("#071019")
const C_FLOOR := Color("#101E24")
const C_COVER := Color("#263A40")
const C_LINE := Color("#31585C")
const C_TEXT := Color("#ECF3F2")
const C_MUTED := Color("#82959A")
const C_CYAN := Color("#73DDD7")
const C_AMBER := Color("#F1B66E")
const C_RED := Color("#EF7773")
const C_GREEN := Color("#72C58D")

var player: CharacterBody3D
var head: Node3D
var camera: Camera3D
var weapon_ray: RayCast3D
var targets: Array[StaticBody3D] = []

var round_time := 115.0
var fire_cooldown := 0.0
var ammo := 30
var health := 100
var targets_left := 3
var mouse_sensitivity := 0.002

var timer_label: Label
var ammo_label: Label
var target_label: Label
var status_label: Label
var crosshair: Label

func _ready() -> void:
	get_window().min_size = Vector2i(800, 500)
	build_world()
	build_player()
	build_hud()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var input_vector := Vector2.ZERO
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1.0
	if Input.is_key_pressed(KEY_W):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_vector.y += 1.0

	var direction := Vector3(input_vector.x, 0.0, input_vector.y)
	if direction.length_squared() > 0.0:
		direction = (player.global_transform.basis * direction).normalized()
	player.velocity.x = direction.x * 5.5
	player.velocity.z = direction.z * 5.5
	if not player.is_on_floor():
		player.velocity.y -= 18.0 * delta
	else:
		player.velocity.y = -0.2
	player.move_and_slide()

	fire_cooldown = maxf(fire_cooldown - delta, 0.0)
	round_time = maxf(round_time - delta, 0.0)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		fire_weapon()
	update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		player.rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x, -1.35, 1.35)
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		exit_to_menu()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		fire_weapon()

func build_world() -> void:
	var environment_node := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#071019")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#4D6C72")
	environment.ambient_light_energy = 0.7
	environment_node.environment = environment
	add_child(environment_node)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55.0, -28.0, 0.0)
	sun.light_color = Color("#B8D3D1")
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)

	create_box("Floor", Vector3(0.0, -0.25, 0.0), Vector3(30.0, 0.5, 24.0), C_FLOOR)
	create_box("NorthWall", Vector3(0.0, 2.0, -12.0), Vector3(30.0, 4.0, 0.5), C_COVER)
	create_box("SouthWall", Vector3(0.0, 2.0, 12.0), Vector3(30.0, 4.0, 0.5), C_COVER)
	create_box("WestWall", Vector3(-15.0, 2.0, 0.0), Vector3(0.5, 4.0, 24.0), C_COVER)
	create_box("EastWall", Vector3(15.0, 2.0, 0.0), Vector3(0.5, 4.0, 24.0), C_COVER)
	create_box("CoverA", Vector3(-2.5, 0.8, -3.5), Vector3(5.0, 1.6, 0.8), C_COVER)
	create_box("CoverB", Vector3(3.5, 0.8, 3.0), Vector3(5.5, 1.6, 0.8), C_COVER)
	create_box("CoverC", Vector3(8.0, 1.2, -1.0), Vector3(1.0, 2.4, 4.0), C_COVER)
	create_box("Objective", Vector3(9.0, 0.03, -4.0), Vector3(3.2, 0.06, 3.2), C_CYAN, true)

	create_target("TargetA", Vector3(6.0, 1.0, -6.0))
	create_target("TargetB", Vector3(10.0, 1.0, 4.8))
	create_target("TargetC", Vector3(2.0, 1.0, -8.0))

func build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(-8.0, 1.0, 7.0)
	player.floor_snap_length = 0.2
	add_child(player)

	var capsule := CollisionShape3D.new()
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = 0.38
	capsule_shape.height = 1.8
	capsule.shape = capsule_shape
	player.add_child(capsule)

	head = Node3D.new()
	head.name = "Head"
	head.position = Vector3(0.0, 0.65, 0.0)
	player.add_child(head)

	camera = Camera3D.new()
	camera.name = "Camera3D"
	camera.current = true
	camera.fov = 94.0
	camera.near = 0.05
	camera.far = 120.0
	head.add_child(camera)

	weapon_ray = RayCast3D.new()
	weapon_ray.name = "WeaponRay"
	weapon_ray.target_position = Vector3(0.0, 0.0, -100.0)
	weapon_ray.enabled = true
	weapon_ray.collision_mask = 1
	camera.add_child(weapon_ray)
	weapon_ray.add_exception(player)

func create_box(
	node_name: String,
	position: Vector3,
	box_size: Vector3,
	color: Color,
	glowing := false
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = position
	add_child(body)

	var mesh := MeshInstance3D.new()
	mesh.name = "Mesh"
	var box_mesh := BoxMesh.new()
	box_mesh.size = box_size
	mesh.mesh = box_mesh
	mesh.material_override = make_material(color, glowing)
	body.add_child(mesh)

	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = box_size
	collision.shape = box_shape
	body.add_child(collision)
	return body

func create_target(target_name: String, position: Vector3) -> void:
	var target := StaticBody3D.new()
	target.name = target_name
	target.position = position
	target.add_to_group("target")
	add_child(target)
	targets.append(target)

	var mesh := MeshInstance3D.new()
	mesh.name = "TargetMesh"
	var target_mesh := BoxMesh.new()
	target_mesh.size = Vector3(0.8, 1.8, 0.8)
	mesh.mesh = target_mesh
	mesh.material_override = make_material(Color("#792B38"), true)
	target.add_child(mesh)

	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(0.8, 1.8, 0.8)
	collision.shape = box_shape
	target.add_child(collision)

func fire_weapon() -> void:
	if fire_cooldown > 0.0 or ammo <= 0:
		return
	fire_cooldown = 0.16
	ammo -= 1
	weapon_ray.force_raycast_update()
	if weapon_ray.is_colliding():
		var collider: Node = weapon_ray.get_collider() as Node
		if collider != null and collider.is_in_group("target"):
			var target: StaticBody3D = collider as StaticBody3D
			if is_instance_valid(target):
				target.queue_free()
				targets.erase(target)
				targets_left = max(targets_left - 1, 0)
				status_label.text = "ЦЕЛЬ НЕЙТРАЛИЗОВАНА"
				status_label.visible = true
				get_tree().create_timer(0.9).timeout.connect(_hide_status)
	if ammo == 0:
		ammo = 30
		status_label.text = "ПЕРЕЗАРЯДКА // МАГАЗИН ПОЛОН"
		status_label.visible = true
		get_tree().create_timer(0.9).timeout.connect(_hide_status)

func _hide_status() -> void:
	if is_instance_valid(status_label):
		status_label.visible = false

func update_hud() -> void:
	var minutes := floori(round_time / 60.0)
	var seconds := int(round_time) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
	ammo_label.text = "%02d / 90   FEN-9" % ammo
	target_label.text = "ЦЕЛИ В СЕКТОРЕ     %02d" % targets_left
	if round_time <= 0.0:
		status_label.text = "ВРЕМЯ ВЫШЛО // РАУНД ЗАВЕРШЁН"
		status_label.visible = true

func build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "CombatHUD"
	add_child(layer)
	var hud := Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(hud)

	var top := PanelContainer.new()
	top.anchor_right = 1.0
	top.offset_left = 24.0
	top.offset_top = 16.0
	top.offset_right = -24.0
	top.offset_bottom = 72.0
	top.add_theme_stylebox_override("panel", panel_style(Color("#0B151C"), C_LINE))
	hud.add_child(top)
	var top_margin := MarginContainer.new()
	top_margin.add_theme_constant_override("margin_left", 16)
	top_margin.add_theme_constant_override("margin_right", 12)
	top_margin.add_theme_constant_override("margin_top", 8)
	top_margin.add_theme_constant_override("margin_bottom", 8)
	top.add_child(top_margin)
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 14)
	top_margin.add_child(top_row)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_child(make_label("РАУНД 01 // АТАКА", 12, C_CYAN))
	copy.add_child(make_label("СЕКТОР ГЕЛИКС · ДОСТАВЬ КЛЮЧ В ЯЧЕЙКУ РАЗЛОМА", 8, C_MUTED))
	top_row.add_child(copy)
	timer_label = make_label("01:55", 18, C_TEXT)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top_row.add_child(timer_label)
	top_row.add_child(make_label("●  СЕВЕР ЕВРОПЫ · 32 мс", 8, C_CYAN))
	top_row.add_child(ui_button("ВЫЙТИ В МЕНЮ", Callable(exit_to_menu), false))

	var bottom := PanelContainer.new()
	bottom.anchor_top = 1.0
	bottom.anchor_right = 1.0
	bottom.anchor_bottom = 1.0
	bottom.offset_left = 24.0
	bottom.offset_top = -70.0
	bottom.offset_right = -24.0
	bottom.offset_bottom = -16.0
	bottom.add_theme_stylebox_override("panel", panel_style(Color("#0B151C"), C_LINE))
	hud.add_child(bottom)
	var bottom_margin := MarginContainer.new()
	bottom_margin.add_theme_constant_override("margin_left", 16)
	bottom_margin.add_theme_constant_override("margin_right", 16)
	bottom_margin.add_theme_constant_override("margin_top", 8)
	bottom_margin.add_theme_constant_override("margin_bottom", 8)
	bottom.add_child(bottom_margin)
	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 18)
	bottom_margin.add_child(bottom_row)
	var controls := make_label("W A S D  ДВИЖЕНИЕ     ЛКМ  ОГОНЬ     ESC  МЕНЮ", 8, C_MUTED)
	controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_row.add_child(controls)
	target_label = make_label("ЦЕЛИ В СЕКТОРЕ     03", 9, C_AMBER)
	bottom_row.add_child(target_label)
	bottom_row.add_child(make_label("100 ЗДОРОВЬЯ", 9, C_GREEN))
	ammo_label = make_label("30 / 90   FEN-9", 10, C_TEXT)
	bottom_row.add_child(ammo_label)

	crosshair = make_label("+", 22, C_TEXT)
	crosshair.anchor_left = 0.5
	crosshair.anchor_right = 0.5
	crosshair.anchor_top = 0.5
	crosshair.anchor_bottom = 0.5
	crosshair.offset_left = -12.0
	crosshair.offset_right = 12.0
	crosshair.offset_top = -18.0
	crosshair.offset_bottom = 18.0
	crosshair.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crosshair.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud.add_child(crosshair)

	status_label = make_label("3D-МАТЧ ЗАПУЩЕН // СИСТЕМА ГОТОВА", 14, C_CYAN)
	status_label.anchor_left = 0.5
	status_label.anchor_right = 0.5
	status_label.anchor_top = 0.5
	status_label.anchor_bottom = 0.5
	status_label.offset_left = -220.0
	status_label.offset_right = 220.0
	status_label.offset_top = -58.0
	status_label.offset_bottom = -22.0
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.add_theme_stylebox_override("normal", panel_style(Color("#102A2D"), C_CYAN))
	status_label.z_index = 5
	hud.add_child(status_label)

func exit_to_menu() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	call_deferred("_return_to_menu")

func _return_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func make_material(color: Color, glowing := false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.72
	if glowing:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 0.35
	return material

func make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	return label

func ui_button(text: String, callback: Callable, accent: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 34)
	button.add_theme_font_size_override("font_size", 9)
	button.add_theme_color_override("font_color", C_BG if accent else C_MUTED)
	button.add_theme_color_override("font_hover_color", C_BG if accent else C_CYAN)
	var normal_fill := C_CYAN if accent else Color("#101B21")
	var hover_fill := Color("#9AF0EA") if accent else Color("#152A30")
	var normal_border := C_CYAN if accent else C_LINE
	button.add_theme_stylebox_override("normal", panel_style(normal_fill, normal_border))
	button.add_theme_stylebox_override("hover", panel_style(hover_fill, C_CYAN))
	if callback.is_valid():
		button.pressed.connect(callback)
	return button

func panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()
