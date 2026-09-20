extends Node3D  # gdlint: ignore=max-public-methods
## KS3 — Sandstone: локальный 3D tactical shooter slice.
## WASD — движение, мышь — поворот камеры и огонь, Q/E — смена оружия,
## 1–0 — быстрый выбор слотов, R — перезарядка, Esc — выход в меню.

const Arsenal = preload("res://scripts/arsenal.gd")

const C_SKY := Color("#2E2520")
const C_SAND_FLOOR := Color("#9B6B45")
const C_SAND := Color("#B98250")
const C_SAND_LIGHT := Color("#D0A06A")
const C_SAND_DARK := Color("#634431")
const C_SAND_SHADOW := Color("#432F29")
const C_TEAL := Color("#4CB7AE")
const C_CLOTH := Color("#17615F")
const C_WOOD := Color("#4C3429")
const C_LINE := Color("#D4A36E")
const C_TEXT := Color("#FFF1D5")
const C_MUTED := Color("#C7AD8C")
const C_AMBER := Color("#F0B56F")
const C_RED := Color("#E67C68")
const C_GREEN := Color("#86D39D")

var player: CharacterBody3D
var head: Node3D
var camera: Camera3D
var weapon_ray: RayCast3D
var weapon_mesh: MeshInstance3D
var targets: Array[StaticBody3D] = []
var weapon_catalog: Array[Dictionary] = Arsenal.WEAPONS.duplicate(true)

var round_time := 180.0
var fire_cooldown := 0.0
var current_ammo := 30
var reserve_ammo := 90
var health := 100
var targets_left := 3
var active_weapon_index := 0
var mouse_sensitivity := 0.002
var camera_yaw := 0.0
var camera_pitch := 0.0

var timer_label: Label
var weapon_label: Label
var weapon_slot_label: Label
var ammo_label: Label
var target_label: Label
var status_label: Label


func _ready() -> void:
	get_window().min_size = Vector2i(800, 500)
	build_world()
	build_player()
	build_hud()
	select_weapon(0)
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


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			camera_yaw -= event.relative.x * mouse_sensitivity
			camera_pitch = clampf(camera_pitch - event.relative.y * mouse_sensitivity, -1.35, 1.35)
			player.rotation.y = camera_yaw
			head.rotation.x = camera_pitch
			get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			exit_to_menu()
		elif event.keycode == KEY_Q:
			select_weapon(active_weapon_index - 1)
		elif event.keycode == KEY_E:
			select_weapon(active_weapon_index + 1)
		elif event.keycode == KEY_R:
			reload_weapon()
		elif event.keycode >= KEY_1 and event.keycode <= KEY_9:
			select_weapon(event.keycode - KEY_1)
		elif event.keycode == KEY_0:
			select_weapon(9)
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				fire_weapon()
			get_viewport().set_input_as_handled()


func build_world() -> void:
	var environment_node := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = C_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#C38D69")
	environment.ambient_light_energy = 0.72
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment_node.environment = environment
	add_child(environment_node)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-54.0, -28.0, 0.0)
	sun.light_color = Color("#FFD2A0")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)

	create_box("SandstoneFloor", Vector3(0.0, -0.25, 0.0), Vector3(44.0, 0.5, 32.0), C_SAND_FLOOR)
	create_box("NorthRampart", Vector3(0.0, 2.5, -16.0), Vector3(44.0, 5.0, 0.8), C_SAND_DARK)
	create_box("SouthRampart", Vector3(0.0, 2.5, 16.0), Vector3(44.0, 5.0, 0.8), C_SAND_DARK)
	create_box("WestRampart", Vector3(-22.0, 2.5, 0.0), Vector3(0.8, 5.0, 32.0), C_SAND_DARK)
	create_box("EastRampart", Vector3(22.0, 2.5, 0.0), Vector3(0.8, 5.0, 32.0), C_SAND_DARK)

	create_archway("NorthGate", Vector3(0.0, 0.0, -15.4), 6.0, 5.0, 1.3, C_SAND_LIGHT)
	create_archway("SouthGate", Vector3(0.0, 0.0, 15.4), 5.0, 4.2, 1.3, C_SAND_LIGHT)
	create_archway("WestGate", Vector3(-21.4, 0.0, 0.0), 5.0, 4.2, 1.3, C_SAND_LIGHT, 90.0)
	create_archway("EastGate", Vector3(21.4, 0.0, -2.0), 5.0, 4.2, 1.3, C_SAND_LIGHT, 90.0)

	build_market_quarter()
	build_central_courtyard()
	build_east_citadel()
	build_south_alleys()
	build_watchtowers()
	create_objective_zone("ObjectiveA", Vector3(-13.0, 0.03, -6.0), C_TEAL)
	create_objective_zone("ObjectiveB", Vector3(13.0, 0.03, 6.0), C_AMBER)

	create_target("TargetA", Vector3(-18.0, 1.0, 4.0))
	create_target("TargetB", Vector3(13.0, 1.0, 8.0))
	create_target("TargetC", Vector3(4.0, 1.0, -11.0))


func build_market_quarter() -> void:
	create_box("MarketHouseWestA", Vector3(-16.5, 2.4, -9.0), Vector3(7.0, 4.8, 3.0), C_SAND)
	create_box("MarketHouseWestB", Vector3(-16.5, 2.4, 2.0), Vector3(7.0, 4.8, 3.0), C_SAND)
	create_box("MarketHouseSouth", Vector3(-11.0, 2.4, 10.5), Vector3(11.0, 4.8, 3.0), C_SAND)
	create_archway("MarketNorthArc", Vector3(-16.0, 0.0, -6.7), 3.0, 3.8, 1.0, C_SAND_LIGHT, 90.0)
	create_archway("MarketSouthArc", Vector3(-16.0, 0.0, 5.5), 3.0, 3.8, 1.0, C_SAND_LIGHT, 90.0)
	create_market_stall(Vector3(-10.5, 0.0, -5.0), C_CLOTH)
	create_market_stall(Vector3(-8.5, 0.0, 2.5), C_AMBER)
	create_box("MarketCover", Vector3(-7.0, 0.9, -1.0), Vector3(3.5, 1.8, 0.8), C_SAND_DARK)
	create_box("MarketBench", Vector3(-14.0, 0.55, 7.0), Vector3(3.0, 1.1, 0.7), C_WOOD)


func build_central_courtyard() -> void:
	create_box("CourtyardNorthWing", Vector3(7.0, 2.4, -13.0), Vector3(12.0, 4.8, 2.5), C_SAND)
	create_box("CourtyardWestWing", Vector3(-3.0, 1.2, -8.8), Vector3(0.8, 2.4, 6.0), C_SAND_LIGHT)
	create_box("CourtyardSouthWall", Vector3(3.0, 1.0, 7.0), Vector3(15.0, 2.0, 0.8), C_SAND_DARK)
	create_archway("CourtyardArch", Vector3(3.0, 0.0, 7.0), 4.5, 4.2, 1.0, C_SAND_LIGHT)
	create_box("CourtyardPlinth", Vector3(3.0, 0.25, -1.0), Vector3(5.0, 0.5, 3.5), C_SAND_LIGHT)
	create_box("CourtyardPool", Vector3(3.0, 0.54, -1.0), Vector3(3.2, 0.08, 1.7), C_TEAL, true)
	create_box("CourtyardCover", Vector3(8.0, 1.0, -5.0), Vector3(2.5, 2.0, 1.0), C_SAND_DARK)
	create_box("CourtyardCoverTwo", Vector3(8.0, 1.0, 2.5), Vector3(1.0, 2.0, 3.2), C_SAND_DARK)
	create_banner(Vector3(0.0, 3.7, -12.2), C_CLOTH)


func build_east_citadel() -> void:
	create_box("CitadelPlatform", Vector3(14.0, 0.55, -3.5), Vector3(10.0, 1.1, 8.0), C_SAND_DARK)
	create_box("CitadelKeep", Vector3(15.0, 3.2, -3.5), Vector3(5.5, 5.3, 3.5), C_SAND)
	create_archway("CitadelDoor", Vector3(11.9, 0.0, -3.5), 3.0, 3.8, 1.0, C_SAND_LIGHT, 90.0)
	create_steps(
		"CitadelSteps", Vector3(8.5, 0.0, 3.0), Vector3(0.0, 0.0, -1.0), 7, 0.28, 0.55, 3.4
	)
	create_box("CitadelBalcony", Vector3(18.0, 3.8, -1.0), Vector3(0.8, 0.7, 3.0), C_SAND_LIGHT)
	create_box("CitadelCover", Vector3(10.0, 1.0, 8.5), Vector3(3.0, 2.0, 0.9), C_SAND_DARK)
	create_banner(Vector3(14.0, 6.0, -3.5), C_TEAL)


func build_south_alleys() -> void:
	create_box("SouthAlleyEast", Vector3(14.5, 2.0, 11.0), Vector3(7.0, 4.0, 2.2), C_SAND)
	create_box("SouthAlleyWall", Vector3(5.0, 1.4, 11.0), Vector3(7.0, 2.8, 0.8), C_SAND_LIGHT)
	create_archway("SouthAlleyArc", Vector3(8.8, 0.0, 11.0), 3.0, 3.6, 1.0, C_SAND_LIGHT, 90.0)
	create_market_stall(Vector3(3.0, 0.0, 12.5), C_CLOTH)
	create_box("SouthCrate", Vector3(-1.0, 0.65, 11.5), Vector3(1.5, 1.3, 1.5), C_WOOD)
	create_box("SouthCrateTwo", Vector3(1.0, 0.4, 9.6), Vector3(1.2, 0.8, 1.2), C_WOOD)


func build_watchtowers() -> void:
	create_box("WestTower", Vector3(-19.0, 3.0, -13.0), Vector3(4.0, 6.0, 4.0), C_SAND_DARK)
	create_box("WestTowerTop", Vector3(-19.0, 6.2, -13.0), Vector3(4.8, 0.5, 4.8), C_SAND_LIGHT)
	create_box("EastTower", Vector3(19.0, 3.0, 13.0), Vector3(4.0, 6.0, 4.0), C_SAND_DARK)
	create_box("EastTowerTop", Vector3(19.0, 6.2, 13.0), Vector3(4.8, 0.5, 4.8), C_SAND_LIGHT)


func build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(-18.0, 1.0, 13.0)
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
	camera.fov = 92.0
	camera.near = 0.05
	camera.far = 150.0
	head.add_child(camera)

	weapon_ray = RayCast3D.new()
	weapon_ray.name = "WeaponRay"
	weapon_ray.target_position = Vector3(0.0, 0.0, -100.0)
	weapon_ray.enabled = true
	weapon_ray.collision_mask = 1
	camera.add_child(weapon_ray)
	weapon_ray.add_exception(player)


func select_weapon(index: int) -> void:
	if weapon_catalog.is_empty():
		return
	active_weapon_index = posmod(index, weapon_catalog.size())
	var spec: Dictionary = weapon_catalog[active_weapon_index]
	current_ammo = int(spec["magazine"])
	reserve_ammo = int(spec["reserve"])
	weapon_ray.target_position = Vector3(0.0, 0.0, -3.2 if bool(spec["is_knife"]) else -100.0)
	if is_instance_valid(weapon_mesh):
		weapon_mesh.queue_free()
	weapon_mesh = MeshInstance3D.new()
	weapon_mesh.name = "FirstPersonWeapon"
	var weapon_box := BoxMesh.new()
	weapon_box.size = (
		Vector3(0.09, 0.09, 0.85) if bool(spec["is_knife"]) else Vector3(0.18, 0.18, 0.78)
	)
	weapon_mesh.mesh = weapon_box
	weapon_mesh.position = Vector3(0.46, -0.36, -0.72)
	weapon_mesh.rotation_degrees = Vector3(-4.0, -8.0, 0.0)
	weapon_mesh.material_override = make_material(spec["color"] as Color, false)
	camera.add_child(weapon_mesh)
	status_label.text = "ВЫБРАНО // " + str(spec["name"])
	status_label.visible = true
	get_tree().create_timer(0.8).timeout.connect(_hide_status)
	update_hud()


func reload_weapon() -> void:
	var spec: Dictionary = weapon_catalog[active_weapon_index]
	if bool(spec["is_knife"]):
		status_label.text = "НОЖ ГОТОВ // БЛИЖНИЙ БОЙ"
	else:
		current_ammo = int(spec["magazine"])
		reserve_ammo = int(spec["reserve"])
		status_label.text = "ПЕРЕЗАРЯДКА // " + str(spec["name"])
	status_label.visible = true
	get_tree().create_timer(0.8).timeout.connect(_hide_status)
	update_hud()


func fire_weapon() -> void:
	var spec: Dictionary = weapon_catalog[active_weapon_index]
	if fire_cooldown > 0.0:
		return
	if not bool(spec["is_knife"]) and current_ammo <= 0:
		reload_weapon()
		return

	fire_cooldown = float(spec["cooldown"])
	if not bool(spec["is_knife"]):
		current_ammo -= 1

	var shot_distance := 3.2 if bool(spec["is_knife"]) else 100.0
	var collider: Node = null
	weapon_ray.target_position = Vector3(0.0, 0.0, -shot_distance)
	weapon_ray.force_raycast_update()
	if weapon_ray.is_colliding():
		collider = weapon_ray.get_collider() as Node
	else:
		var query := PhysicsRayQueryParameters3D.create(
			camera.global_position,
			camera.global_position - camera.global_transform.basis.z * shot_distance
		)
		query.collision_mask = 1
		query.exclude = [player.get_rid()]
		var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
		collider = result.get("collider") as Node if not result.is_empty() else null

	var hit_target := resolve_target_hit(collider, spec)
	if hit_target:
		status_label.text = "ЦЕЛЬ НЕЙТРАЛИЗОВАНА // " + str(spec["name"])
	else:
		status_label.text = "ВЫСТРЕЛ // " + str(spec["name"])
	status_label.visible = true
	get_tree().create_timer(0.45 if not hit_target else 0.9).timeout.connect(_hide_status)
	update_hud()


func resolve_target_hit(collider: Node, _spec: Dictionary) -> bool:
	if collider == null or not collider.is_in_group("target"):
		return false
	var target: StaticBody3D = collider as StaticBody3D
	if not is_instance_valid(target):
		return false
	target.queue_free()
	targets.erase(target)
	targets_left = max(targets_left - 1, 0)
	return true


func create_box(
	node_name: String,
	box_position: Vector3,
	box_size: Vector3,
	color: Color,
	glowing: bool = false,
	box_rotation_degrees: Vector3 = Vector3.ZERO
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = box_position
	body.rotation_degrees = box_rotation_degrees
	body.collision_layer = 1
	body.collision_mask = 1
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


func create_archway(
	arch_name: String,
	arch_position: Vector3,
	width: float,
	height: float,
	depth: float,
	color: Color,
	rotation_y: float = 0.0
) -> void:
	var sideways := Vector3(cos(deg_to_rad(rotation_y)), 0.0, sin(deg_to_rad(rotation_y)))
	var column_size := Vector3(0.6, height, depth)
	var beam_size := Vector3(width, 0.7, depth)
	if absf(sideways.z) > 0.5:
		column_size = Vector3(depth, height, 0.6)
		beam_size = Vector3(depth, 0.7, width)
	create_box(arch_name + "Left", arch_position - sideways * width * 0.5, column_size, color)
	create_box(arch_name + "Right", arch_position + sideways * width * 0.5, column_size, color)
	create_box(
		arch_name + "Lintel", arch_position + Vector3(0.0, height - 0.35, 0.0), beam_size, color
	)
	create_box(
		arch_name + "Crown",
		arch_position + Vector3(0.0, height + 0.25, 0.0),
		beam_size * Vector3(1.12, 0.7, 1.0),
		C_SAND_DARK
	)


func create_steps(
	step_name: String,
	start: Vector3,
	direction: Vector3,
	count: int,
	rise: float,
	run: float,
	width: float
) -> void:
	for index in range(count):
		var step_height := rise * float(index + 1)
		var step_position := start + direction * run * float(index)
		step_position.y = step_height * 0.5
		var step_size := Vector3(width, step_height, run)
		if absf(direction.x) > 0.5:
			step_size = Vector3(run, step_height, width)
		create_box(step_name + str(index), step_position, step_size, C_SAND_LIGHT)


func create_market_stall(stall_position: Vector3, cloth_color: Color) -> void:
	create_box(
		"StallCounter", stall_position + Vector3(0.0, 0.55, 0.0), Vector3(2.8, 1.1, 1.2), C_WOOD
	)
	create_box(
		"StallRoof",
		stall_position + Vector3(0.0, 2.4, 0.0),
		Vector3(3.4, 0.18, 1.8),
		cloth_color,
		true
	)
	create_box(
		"StallPostA", stall_position + Vector3(-1.35, 1.35, -0.65), Vector3(0.15, 2.7, 0.15), C_WOOD
	)
	create_box(
		"StallPostB", stall_position + Vector3(1.35, 1.35, -0.65), Vector3(0.15, 2.7, 0.15), C_WOOD
	)


func create_banner(banner_position: Vector3, color: Color) -> void:
	create_box(
		"BannerPole", banner_position + Vector3(-0.8, -1.2, 0.0), Vector3(0.08, 2.8, 0.08), C_WOOD
	)
	create_box(
		"BannerCloth",
		banner_position + Vector3(0.0, -0.8, 0.0),
		Vector3(1.4, 1.4, 0.08),
		color,
		true
	)


func create_objective_zone(zone_name: String, zone_position: Vector3, color: Color) -> void:
	create_box(zone_name, zone_position, Vector3(4.0, 0.08, 4.0), color, true)
	create_box(
		zone_name + "Marker",
		zone_position + Vector3(0.0, 0.2, 0.0),
		Vector3(0.15, 0.35, 4.4),
		color,
		true
	)
	create_box(
		zone_name + "MarkerCross",
		zone_position + Vector3(0.0, 0.2, 0.0),
		Vector3(4.4, 0.35, 0.15),
		color,
		true
	)


func create_target(target_name: String, target_position: Vector3) -> void:
	var target := StaticBody3D.new()
	target.name = target_name
	target.position = target_position
	target.collision_layer = 1
	target.collision_mask = 1
	target.add_to_group("target")
	add_child(target)
	targets.append(target)

	var mesh := MeshInstance3D.new()
	mesh.name = "TargetMesh"
	var target_mesh := BoxMesh.new()
	target_mesh.size = Vector3(0.8, 1.8, 0.8)
	mesh.mesh = target_mesh
	mesh.material_override = make_material(C_RED, true)
	target.add_child(mesh)

	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(0.8, 1.8, 0.8)
	collision.shape = box_shape
	target.add_child(collision)


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
	top.add_theme_stylebox_override("panel", panel_style(Color("#241A16"), C_LINE))
	hud.add_child(top)
	var top_margin := MarginContainer.new()
	set_margins(top_margin, 16, 12, 8, 8)
	top.add_child(top_margin)
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 14)
	top_margin.add_child(top_row)
	var title := VBoxContainer.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_child(make_label("SANDSTONE // РАУНД 01", 12, C_AMBER))
	title.add_child(make_label("ГОРОД ПЕСКА · ДВА ОБЪЕКТИВА · КОНТРОЛЬ ЦЕНТРА", 8, C_MUTED))
	top_row.add_child(title)
	timer_label = make_label("03:00", 18, C_TEXT)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top_row.add_child(timer_label)
	top_row.add_child(make_label("●  ПОЛЕВОЙ КАНАЛ · 32 мс", 8, C_TEAL))
	top_row.add_child(ui_button("ВЫЙТИ", Callable(exit_to_menu), false))

	var bottom := PanelContainer.new()
	bottom.anchor_top = 1.0
	bottom.anchor_right = 1.0
	bottom.anchor_bottom = 1.0
	bottom.offset_left = 24.0
	bottom.offset_top = -78.0
	bottom.offset_right = -24.0
	bottom.offset_bottom = -16.0
	bottom.add_theme_stylebox_override("panel", panel_style(Color("#241A16"), C_LINE))
	hud.add_child(bottom)
	var bottom_margin := MarginContainer.new()
	set_margins(bottom_margin, 16, 16, 8, 8)
	bottom.add_child(bottom_margin)
	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 16)
	bottom_margin.add_child(bottom_row)
	var controls := make_label(
		"W A S D  ДВИЖЕНИЕ    МЫШЬ  КАМЕРА/ОГОНЬ    Q/E  АРСЕНАЛ    R  ПЕРЕЗАРЯДКА", 8, C_MUTED
	)
	controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_row.add_child(controls)
	weapon_slot_label = make_label("01 / 30", 9, C_AMBER)
	bottom_row.add_child(weapon_slot_label)
	weapon_label = make_label("FEN-9 COBALT", 9, C_TEXT)
	bottom_row.add_child(weapon_label)
	ammo_label = make_label("30 / 90", 10, C_TEXT)
	bottom_row.add_child(ammo_label)
	target_label = make_label("ЦЕЛИ 03", 9, C_GREEN)
	bottom_row.add_child(target_label)

	var crosshair := make_label("+", 22, C_TEXT)
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

	status_label = make_label("SANDSTONE // СИСТЕМА ГОТОВА", 14, C_AMBER)
	status_label.anchor_left = 0.5
	status_label.anchor_right = 0.5
	status_label.anchor_top = 0.5
	status_label.anchor_bottom = 0.5
	status_label.offset_left = -240.0
	status_label.offset_right = 240.0
	status_label.offset_top = -58.0
	status_label.offset_bottom = -22.0
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.add_theme_stylebox_override("normal", panel_style(Color("#3B281D"), C_AMBER))
	status_label.z_index = 5
	hud.add_child(status_label)


func update_hud() -> void:
	var minutes := floori(round_time / 60.0)
	var seconds := int(round_time) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
	var spec: Dictionary = weapon_catalog[active_weapon_index]
	weapon_slot_label.text = "%02d / %02d" % [active_weapon_index + 1, weapon_catalog.size()]
	weapon_label.text = str(spec["name"])
	if bool(spec["is_knife"]):
		ammo_label.text = "∞  БЛИЖНИЙ БОЙ"
	else:
		ammo_label.text = "%02d / %02d" % [current_ammo, reserve_ammo]
	target_label.text = "ЦЕЛИ %02d" % targets_left
	if round_time <= 0.0:
		status_label.text = "ВРЕМЯ ВЫШЛО // РАУНД ЗАВЕРШЁН"
		status_label.visible = true


func _hide_status() -> void:
	if is_instance_valid(status_label):
		status_label.visible = false


func exit_to_menu() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	call_deferred("_return_to_menu")


func _return_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func set_margins(container: MarginContainer, left: int, right: int, top: int, bottom: int) -> void:
	container.add_theme_constant_override("margin_left", left)
	container.add_theme_constant_override("margin_right", right)
	container.add_theme_constant_override("margin_top", top)
	container.add_theme_constant_override("margin_bottom", bottom)


func make_material(color: Color, glowing: bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	if glowing:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 0.28
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
	button.add_theme_color_override("font_color", Color("#281A13") if accent else C_MUTED)
	button.add_theme_color_override("font_hover_color", Color("#281A13") if accent else C_TEXT)
	var normal_fill := C_AMBER if accent else Color("#34241C")
	var hover_fill := Color("#FFD49B") if accent else Color("#4A3023")
	button.add_theme_stylebox_override(
		"normal", panel_style(normal_fill, C_LINE if accent else C_SAND_DARK)
	)
	button.add_theme_stylebox_override("hover", panel_style(hover_fill, C_AMBER))
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
