extends Node3D  # gdlint: ignore=max-public-methods
## KS3 — Sandstone: локальный 3D tactical shooter slice.
## WASD — движение, мышь — поворот камеры и огонь, Q/E — смена оружия,
## 1–0 — быстрый выбор слотов, R — перезарядка, Esc — выход в меню.

const Arsenal = preload("res://scripts/arsenal.gd")
const SHOT_STREAM = preload("res://assets/audio/ks3_shot.wav")
const BOT_SHOT_STREAM = preload("res://assets/audio/ks3_bot_shot.wav")
const HIT_STREAM = preload("res://assets/audio/ks3_hit.wav")
const RELOAD_STREAM = preload("res://assets/audio/ks3_reload.wav")
const SWITCH_STREAM = preload("res://assets/audio/ks3_switch.wav")
const MUSIC_STREAM = preload("res://assets/audio/ks3_sandstone_ambient.wav")

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
var muzzle_flash: OmniLight3D
var targets: Array[StaticBody3D] = []
var bots: Array[Dictionary] = []
var weapon_catalog: Array[Dictionary] = Arsenal.WEAPONS.duplicate(true)

var music_player: AudioStreamPlayer
var shot_player: AudioStreamPlayer
var bot_shot_player: AudioStreamPlayer
var hit_player: AudioStreamPlayer
var reload_player: AudioStreamPlayer
var switch_player: AudioStreamPlayer

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
var health_label: Label
var bots_label: Label
var status_label: Label


func _ready() -> void:
	get_window().min_size = Vector2i(800, 500)
	build_world()
	build_player()
	build_bots()
	build_audio()
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
	update_bots(delta)
	if health <= 0:
		respawn_player()
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

	muzzle_flash = OmniLight3D.new()
	muzzle_flash.name = "MuzzleFlash"
	muzzle_flash.light_color = C_AMBER
	muzzle_flash.light_energy = 4.5
	muzzle_flash.omni_range = 3.5
	muzzle_flash.position = Vector3(0.35, -0.28, -1.0)
	muzzle_flash.visible = false
	camera.add_child(muzzle_flash)


func build_bots() -> void:
	create_bot(
		"BotVanta",
		Vector3(5.0, 1.0, -5.0),
		1,
		[Vector3(5.0, 1.0, -5.0), Vector3(9.0, 1.0, -2.0), Vector3(5.0, 1.0, 1.0)]
	)
	create_bot(
		"BotRift",
		Vector3(13.0, 1.0, 8.0),
		6,
		[Vector3(13.0, 1.0, 8.0), Vector3(16.0, 1.0, 4.0), Vector3(12.0, 1.0, 1.0)]
	)
	create_bot(
		"BotTalon",
		Vector3(-8.0, 1.0, -5.0),
		12,
		[Vector3(-8.0, 1.0, -5.0), Vector3(-4.0, 1.0, -3.0), Vector3(-6.0, 1.0, -8.0)]
	)


func create_bot(
	bot_name: String, bot_position: Vector3, weapon_index: int, patrol_points: Array
) -> void:
	var bot := CharacterBody3D.new()
	bot.name = bot_name
	bot.position = bot_position
	bot.collision_layer = 1
	bot.collision_mask = 1
	bot.floor_snap_length = 0.2
	bot.add_to_group("bot")
	add_child(bot)

	var capsule := CollisionShape3D.new()
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = 0.38
	capsule_shape.height = 1.8
	capsule.shape = capsule_shape
	bot.add_child(capsule)

	var body_mesh := MeshInstance3D.new()
	var body_shape := CapsuleMesh.new()
	body_shape.radius = 0.38
	body_shape.height = 1.8
	body_mesh.mesh = body_shape
	body_mesh.material_override = make_material(C_RED, false)
	bot.add_child(body_mesh)

	var bot_weapon := MeshInstance3D.new()
	var weapon_shape := BoxMesh.new()
	weapon_shape.size = Vector3(0.16, 0.16, 0.72)
	bot_weapon.mesh = weapon_shape
	bot_weapon.position = Vector3(0.36, 0.55, -0.35)
	bot_weapon.rotation_degrees = Vector3(-6.0, -12.0, 0.0)
	bot_weapon.material_override = make_material(
		weapon_catalog[weapon_index]["color"] as Color, false
	)
	bot.add_child(bot_weapon)

	bots.append(
		{
			"node": bot,
			"weapon": weapon_catalog[weapon_index],
			"cooldown": 0.8,
			"patrol": patrol_points,
			"patrol_index": 0,
			"strafe": 1.0 if bots.size() % 2 == 0 else -1.0
		}
	)


func build_audio() -> void:
	music_player = make_audio_player(MUSIC_STREAM, -17.0)
	music_player.finished.connect(func() -> void: music_player.play())
	music_player.play()
	shot_player = make_audio_player(SHOT_STREAM, -7.0)
	bot_shot_player = make_audio_player(BOT_SHOT_STREAM, -12.0)
	hit_player = make_audio_player(HIT_STREAM, -5.0)
	reload_player = make_audio_player(RELOAD_STREAM, -8.0)
	switch_player = make_audio_player(SWITCH_STREAM, -9.0)


func make_audio_player(stream: AudioStream, volume_db: float) -> AudioStreamPlayer:
	var player_node := AudioStreamPlayer.new()
	player_node.stream = stream
	player_node.volume_db = volume_db
	add_child(player_node)
	return player_node


func select_weapon(index: int) -> void:
	if weapon_catalog.is_empty():
		return
	if (
		is_instance_valid(switch_player)
		and active_weapon_index != posmod(index, weapon_catalog.size())
	):
		switch_player.play()
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
	if is_instance_valid(reload_player):
		reload_player.play()
	if bool(spec["is_knife"]):
		status_label.text = "НОЖ ГОТОВ // БЛИЖНИЙ БОЙ"
	else:
		current_ammo = int(spec["magazine"])
		reserve_ammo = int(spec["reserve"])
		status_label.text = "ПЕРЕЗАРЯДКА // " + str(spec["name"])
	status_label.visible = true
	get_tree().create_timer(0.8).timeout.connect(_hide_status)
	update_hud()


func update_bots(delta: float) -> void:
	for bot_data in bots:
		var bot: CharacterBody3D = bot_data["node"] as CharacterBody3D
		if not is_instance_valid(bot):
			continue
		var to_player := player.global_position - bot.global_position
		var flat_to_player := Vector3(to_player.x, 0.0, to_player.z)
		var distance := flat_to_player.length()
		var sees_player := bot_can_see_player(bot)
		bot_data["cooldown"] = maxf(float(bot_data["cooldown"]) - delta, 0.0)
		var desired := Vector3.ZERO
		if sees_player and distance > 0.1:
			bot.look_at(
				Vector3(player.global_position.x, bot.global_position.y, player.global_position.z),
				Vector3.UP
			)
			if distance > 14.0:
				desired = flat_to_player.normalized()
			elif distance < 7.0:
				desired = -flat_to_player.normalized()
			else:
				var side := Vector3(-flat_to_player.z, 0.0, flat_to_player.x).normalized()
				desired = side * float(bot_data["strafe"])
			if float(bot_data["cooldown"]) <= 0.0 and distance < 45.0:
				bot_fire(bot_data)
		else:
			var patrol: Array = bot_data["patrol"]
			var patrol_index := int(bot_data["patrol_index"])
			var patrol_target: Vector3 = patrol[patrol_index]
			var to_patrol := patrol_target - bot.global_position
			to_patrol.y = 0.0
			if to_patrol.length() < 0.8:
				bot_data["patrol_index"] = (patrol_index + 1) % patrol.size()
			else:
				desired = to_patrol.normalized()
				bot.look_at(bot.global_position + desired, Vector3.UP)
		bot.velocity.x = desired.x * 2.4
		bot.velocity.z = desired.z * 2.4
		if not bot.is_on_floor():
			bot.velocity.y -= 18.0 * delta
		else:
			bot.velocity.y = -0.2
		bot.move_and_slide()


func bot_can_see_player(bot: CharacterBody3D) -> bool:
	var from := bot.global_position + Vector3(0.0, 0.75, 0.0)
	var to := player.global_position + Vector3(0.0, 0.65, 0.0)
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1
	query.exclude = [bot.get_rid()]
	var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	return not result.is_empty() and result.get("collider") == player


func bot_fire(bot_data: Dictionary) -> void:
	var bot: CharacterBody3D = bot_data["node"] as CharacterBody3D
	var spec: Dictionary = bot_data["weapon"]
	var from := bot.global_position + Vector3(0.0, 0.75, 0.0)
	var to := player.global_position + Vector3(0.0, 0.65, 0.0)
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1
	query.exclude = [bot.get_rid()]
	var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	var hit_position := to
	if not result.is_empty():
		hit_position = result["position"]
	show_shot_visual(from, hit_position, C_RED)
	if not result.is_empty():
		show_impact(hit_position, C_RED if result.get("collider") == player else C_AMBER)
	bot_shot_player.pitch_scale = randf_range(0.92, 1.08)
	bot_shot_player.play()
	bot_data["cooldown"] = maxf(0.28, float(spec["cooldown"]) * 4.0)
	if not result.is_empty() and result.get("collider") == player:
		health = maxi(0, health - maxi(2, int(int(spec["damage"]) / 9)))
		status_label.text = "БОТ ПОПАЛ // " + str(spec["name"])
		status_label.visible = true
		get_tree().create_timer(0.5).timeout.connect(_hide_status)


func respawn_player() -> void:
	health = 100
	player.global_position = Vector3(-18.0, 1.0, 13.0)
	player.velocity = Vector3.ZERO
	camera_yaw = 0.0
	camera_pitch = 0.0
	player.rotation.y = camera_yaw
	head.rotation.x = camera_pitch
	status_label.text = "ВОЗВРАТ В РАУНД // БОТЫ СОХРАНЯЮТ ОРУЖИЕ"
	status_label.visible = true
	get_tree().create_timer(1.0).timeout.connect(_hide_status)


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
	var hit_position := camera.global_position - camera.global_transform.basis.z * shot_distance
	weapon_ray.target_position = Vector3(0.0, 0.0, -shot_distance)
	weapon_ray.force_raycast_update()
	if weapon_ray.is_colliding():
		collider = weapon_ray.get_collider() as Node
		hit_position = weapon_ray.get_collision_point()
	else:
		var query := PhysicsRayQueryParameters3D.create(
			camera.global_position,
			camera.global_position - camera.global_transform.basis.z * shot_distance
		)
		query.collision_mask = 1
		query.exclude = [player.get_rid()]
		var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
		if not result.is_empty():
			collider = result.get("collider") as Node
			hit_position = result["position"]

	var hit_target := resolve_target_hit(collider, spec)
	show_shot_visual(camera.global_position, hit_position, C_AMBER)
	if collider != null:
		show_impact(hit_position, C_RED if hit_target else C_AMBER)
	if hit_target:
		status_label.text = "ЦЕЛЬ НЕЙТРАЛИЗОВАНА // " + str(spec["name"])
		hit_player.play()
	else:
		status_label.text = "ВЫСТРЕЛ // " + str(spec["name"])
	status_label.visible = true
	shot_player.pitch_scale = randf_range(0.96, 1.04)
	shot_player.play()
	show_muzzle_flash()
	get_tree().create_timer(0.45 if not hit_target else 0.9).timeout.connect(_hide_status)
	update_hud()


func show_muzzle_flash() -> void:
	muzzle_flash.visible = true
	muzzle_flash.light_energy = 4.5
	get_tree().create_timer(0.055).timeout.connect(_hide_muzzle_flash)


func _hide_muzzle_flash() -> void:
	if is_instance_valid(muzzle_flash):
		muzzle_flash.visible = false


func show_shot_visual(start: Vector3, end: Vector3, color: Color) -> void:
	var tracer_mesh := ImmediateMesh.new()
	var tracer_material := StandardMaterial3D.new()
	tracer_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tracer_material.albedo_color = color
	tracer_material.emission_enabled = true
	tracer_material.emission = color
	tracer_material.emission_energy_multiplier = 3.0
	tracer_mesh.surface_begin(Mesh.PRIMITIVE_LINES, tracer_material)
	tracer_mesh.surface_add_vertex(start)
	tracer_mesh.surface_add_vertex(start.lerp(end, 0.72))
	tracer_mesh.surface_end()
	var tracer := MeshInstance3D.new()
	tracer.name = "ShotTracer"
	tracer.mesh = tracer_mesh
	add_child(tracer)
	get_tree().create_timer(0.07).timeout.connect(tracer.queue_free)


func show_impact(impact_position: Vector3, color: Color) -> void:
	var impact := MeshInstance3D.new()
	impact.name = "ImpactFlash"
	var sphere := SphereMesh.new()
	sphere.radius = 0.10
	sphere.height = 0.20
	impact.mesh = sphere
	impact.position = impact_position
	impact.material_override = make_material(color, true)
	add_child(impact)
	get_tree().create_timer(0.18).timeout.connect(impact.queue_free)


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
	health_label = make_label("HP 100", 10, C_GREEN)
	top_row.add_child(health_label)
	bots_label = make_label("БОТЫ 03", 10, C_RED)
	top_row.add_child(bots_label)
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
	var controls := make_label("WASD ДВИЖЕНИЕ · ЛКМ ОГОНЬ · Q/E АРСЕНАЛ · R", 8, C_MUTED)
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
	health_label.text = "HP %03d" % health
	health_label.add_theme_color_override("font_color", C_GREEN if health > 35 else C_RED)
	bots_label.text = "БОТЫ %02d" % bots.size()
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
