extends Control
## Нативный игровой экран KS3: маленький, но реально запускаемый tactical slice.
## WASD — движение, мышь — прицел, левая кнопка — огонь, Esc — выход в меню.

const C_BG := Color("#070C12")
const C_ARENA := Color("#0C1820")
const C_GRID := Color("#1B3038")
const C_LINE := Color("#31585C")
const C_TEXT := Color("#ECF3F2")
const C_MUTED := Color("#82959A")
const C_CYAN := Color("#73DDD7")
const C_AMBER := Color("#F1B66E")
const C_RED := Color("#EF7773")
const C_GREEN := Color("#72C58D")

var player := Vector2(0.18, 0.52)
var enemies: Array[Vector2] = [Vector2(0.72, 0.30), Vector2(0.82, 0.66), Vector2(0.58, 0.48)]
var tracers: Array = []
var round_time := 115.0
var fire_cooldown := 0.0
var status_time := 3.0
var ammo := 30
var health := 100
var objective_progress := 0.0

var timer_label: Label
var ammo_label: Label
var objective_label: Label
var status_label: Label

func _ready() -> void:
	get_window().min_size = Vector2i(800, 500)
	build_hud()
	queue_redraw()

func _process(delta: float) -> void:
	var movement := Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		movement.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		movement.y += 1.0
	if Input.is_key_pressed(KEY_A):
		movement.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		movement.x += 1.0
	if movement.length_squared() > 0.0:
		player += movement.normalized() * 0.28 * delta
	player.x = clampf(player.x, 0.05, 0.95)
	player.y = clampf(player.y, 0.12, 0.88)

	fire_cooldown = maxf(fire_cooldown - delta, 0.0)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and fire_cooldown <= 0.0:
		fire_weapon()

	var active_tracers: Array = []
	for tracer in tracers:
		tracer["ttl"] = float(tracer["ttl"]) - delta
		if tracer["ttl"] > 0.0:
			active_tracers.append(tracer)
	tracers = active_tracers

	round_time = maxf(round_time - delta, 0.0)
	status_time = maxf(status_time - delta, 0.0)
	if round_time <= 0.0:
		status_label.text = "ВРЕМЯ ВЫШЛО // РАУНД ЗАВЕРШЁН"
		status_label.visible = true
	elif status_time <= 0.0:
		status_label.visible = false

	update_hud()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		exit_to_menu()

func fire_weapon() -> void:
	fire_cooldown = 0.16
	ammo -= 1
	if ammo <= 0:
		ammo = 30
		status_label.text = "ПЕРЕЗАРЯДКА // МАГАЗИН ПОЛОН"
		status_label.visible = true
		status_time = 1.0
	var start := player_screen_position()
	var target := get_global_mouse_position()
	tracers.append({"start": start, "end": target, "ttl": 0.08})

func player_screen_position() -> Vector2:
	var arena := arena_rect()
	return arena.position + player * arena.size

func arena_rect() -> Rect2:
	var margin_x := clampf(size.x * 0.045, 24.0, 72.0)
	var top := 84.0
	var bottom := 86.0
	return Rect2(margin_x, top, maxf(size.x - margin_x * 2.0, 1.0), maxf(size.y - top - bottom, 1.0))

func update_hud() -> void:
	var minutes := floori(round_time / 60.0)
	var seconds := int(round_time) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
	ammo_label.text = "%02d / 90   FEN-9" % ammo
	objective_label.text = "ДОСТАВИТЬ КЛЮЧ     %02d%%" % int(objective_progress * 100.0)

func build_hud() -> void:
	var top := PanelContainer.new()
	top.anchor_right = 1.0
	top.offset_left = 24.0
	top.offset_top = 16.0
	top.offset_right = -24.0
	top.offset_bottom = 72.0
	top.add_theme_stylebox_override("panel", panel_style(Color("#0B151C"), C_LINE))
	add_child(top)
	var top_margin := MarginContainer.new()
	top_margin.add_theme_constant_override("margin_left", 16)
	top_margin.add_theme_constant_override("margin_right", 12)
	top_margin.add_theme_constant_override("margin_top", 8)
	top_margin.add_theme_constant_override("margin_bottom", 8)
	top.add_child(top_margin)
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 14)
	top_margin.add_child(top_row)
	var match_copy := VBoxContainer.new()
	match_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	match_copy.add_child(make_label("РАУНД 01 // АТАКА", 12, C_CYAN))
	match_copy.add_child(make_label("СЕКТОР ГЕЛИКС · ДОСТАВЬ КЛЮЧ В ЯЧЕЙКУ РАЗЛОМА", 8, C_MUTED))
	top_row.add_child(match_copy)
	timer_label = make_label("01:55", 18, C_TEXT)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top_row.add_child(timer_label)
	top_row.add_child(make_label("●  СЕВЕР ЕВРОПЫ · 32 мс", 8, C_CYAN))
	var exit_button := ui_button("ВЫЙТИ В МЕНЮ", Callable(exit_to_menu), false)
	top_row.add_child(exit_button)

	var bottom := PanelContainer.new()
	bottom.anchor_top = 1.0
	bottom.anchor_right = 1.0
	bottom.anchor_bottom = 1.0
	bottom.offset_left = 24.0
	bottom.offset_top = -70.0
	bottom.offset_right = -24.0
	bottom.offset_bottom = -16.0
	bottom.add_theme_stylebox_override("panel", panel_style(Color("#0B151C"), C_LINE))
	add_child(bottom)
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
	objective_label = make_label("ДОСТАВИТЬ КЛЮЧ     00%", 9, C_AMBER)
	bottom_row.add_child(objective_label)
	bottom_row.add_child(make_label("100 ЗДОРОВЬЯ", 9, C_GREEN))
	ammo_label = make_label("30 / 90   FEN-9", 10, C_TEXT)
	bottom_row.add_child(ammo_label)

	status_label = make_label("МАТЧ ЗАПУЩЕН // СИСТЕМА ГОТОВА", 14, C_CYAN)
	status_label.anchor_left = 0.5
	status_label.anchor_right = 0.5
	status_label.anchor_top = 0.5
	status_label.anchor_bottom = 0.5
	status_label.offset_left = -190.0
	status_label.offset_right = 190.0
	status_label.offset_top = -20.0
	status_label.offset_bottom = 20.0
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.add_theme_stylebox_override("normal", panel_style(Color("#102A2D"), C_CYAN))
	status_label.z_index = 5
	add_child(status_label)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), C_BG)
	var arena := arena_rect()
	draw_rect(arena, C_ARENA)
	for column in range(1, 13):
		var x := arena.position.x + arena.size.x * float(column) / 13.0
		draw_line(Vector2(x, arena.position.y), Vector2(x, arena.end.y), C_GRID, 1.0)
	for row in range(1, 8):
		var y := arena.position.y + arena.size.y * float(row) / 9.0
		draw_line(Vector2(arena.position.x, y), Vector2(arena.end.x, y), C_GRID, 1.0)

	var site := Rect2(arena.position + Vector2(arena.size.x * 0.72, arena.size.y * 0.20), Vector2(arena.size.x * 0.18, arena.size.y * 0.28))
	draw_rect(site, Color(0.10, 0.36, 0.37, 0.42), true)
	draw_rect(site, C_CYAN, false, 2.0)
	var cover_a := Rect2(arena.position + Vector2(arena.size.x * 0.31, arena.size.y * 0.18), Vector2(arena.size.x * 0.19, 18.0))
	var cover_b := Rect2(arena.position + Vector2(arena.size.x * 0.42, arena.size.y * 0.68), Vector2(arena.size.x * 0.23, 18.0))
	draw_rect(cover_a, Color("#243B42"), true)
	draw_rect(cover_b, Color("#243B42"), true)

	for enemy in enemies:
		var enemy_pos: Vector2 = arena.position + enemy * arena.size
		draw_circle(enemy_pos, 13.0, Color(0.55, 0.18, 0.20, 0.9))
		draw_circle(enemy_pos, 6.0, C_RED)
		draw_line(enemy_pos + Vector2(-18, 20), enemy_pos + Vector2(18, 20), C_RED, 2.0)

	var player_pos := player_screen_position()
	var aim := (get_global_mouse_position() - player_pos).normalized()
	if aim.length_squared() < 0.01:
		aim = Vector2.RIGHT
	draw_circle(player_pos, 16.0, Color(0.12, 0.45, 0.46, 0.65))
	draw_circle(player_pos, 9.0, C_CYAN)
	draw_line(player_pos, player_pos + aim * 32.0, C_TEXT, 3.0)
	draw_circle(player_pos + aim * 40.0, 3.0, C_TEXT)

	for tracer in tracers:
		draw_line(tracer["start"], tracer["end"], C_AMBER, 2.0)

func exit_to_menu() -> void:
	call_deferred("_return_to_menu")

func _return_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

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
	button.add_theme_stylebox_override("normal", panel_style(C_CYAN if accent else Color("#101B21"), C_CYAN if accent else C_LINE))
	button.add_theme_stylebox_override("hover", panel_style(Color("#9AF0EA") if accent else Color("#152A30"), C_CYAN))
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
