extends Control  # gdlint: ignore=max-public-methods
## KS3 — Sandstone: полноэкранный tactical briefing вместо старого command center.
## Главное действие всегда ведёт в 3D-матч, остальные pages открываются как overlays.

const Arsenal = preload("res://scripts/arsenal.gd")
const MENU_TEXTURE = preload("res://assets/sandstone-menu.jpg")
const WEAPON_TEXTURE = preload("res://assets/fen-9-cobalt.jpg")

const C_BG := Color("#120B08")
const C_PANEL := Color("#1A100B")
const C_PANEL_LIGHT := Color("#2B1A11")
const C_SAND := Color("#C58A55")
const C_GOLD := Color("#F3B875")
const C_TEAL := Color("#67D7CC")
const C_TEXT := Color("#FFF0D4")
const C_MUTED := Color("#C7AA87")
const C_DIM := Color("#7C6654")
const C_GREEN := Color("#8AD39A")
const C_RED := Color("#E57C68")

var page_root: Control
var page_scroll: ScrollContainer
var toast: Label
var toast_timer: Timer
var nav_buttons: Dictionary = {}
var current_page := "overview"

var pages := {
	"overview": "Операция",
	"map": "Карта",
	"loadout": "Арсенал",
	"training": "Тренировка",
	"profile": "Оператор",
	"settings": "Настройки",
}


func _ready() -> void:
	get_window().min_size = Vector2i(800, 500)
	build_shell()
	show_page("overview")


func build_shell() -> void:
	var background := TextureRect.new()
	background.texture = MENU_TEXTURE
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.modulate = Color(0.86, 0.68, 0.48, 0.82)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var shade := ColorRect.new()
	shade.color = Color(0.045, 0.022, 0.012, 0.58)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var top_rule := ColorRect.new()
	top_rule.color = Color(0.95, 0.66, 0.38, 0.36)
	top_rule.anchor_right = 1.0
	top_rule.offset_top = 76.0
	top_rule.offset_bottom = 77.0
	top_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_rule)

	build_header()

	page_scroll = ScrollContainer.new()
	page_scroll.name = "BriefingPages"
	page_scroll.anchor_right = 1.0
	page_scroll.anchor_bottom = 1.0
	page_scroll.offset_left = 34.0
	page_scroll.offset_top = 92.0
	page_scroll.offset_right = -34.0
	page_scroll.offset_bottom = -78.0
	page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	add_child(page_scroll)

	page_root = VBoxContainer.new()
	page_root.name = "PageRoot"
	page_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_root.add_theme_constant_override("separation", 12)
	page_scroll.add_child(page_root)

	var footer := PanelContainer.new()
	footer.anchor_top = 1.0
	footer.anchor_right = 1.0
	footer.anchor_bottom = 1.0
	footer.offset_left = 24.0
	footer.offset_top = -60.0
	footer.offset_right = -24.0
	footer.offset_bottom = -18.0
	footer.add_theme_stylebox_override("panel", panel_style(Color("#120B0BE8"), Color("#745038")))
	add_child(footer)
	var footer_margin := MarginContainer.new()
	set_margins(footer_margin, 12, 14, 7, 7)
	footer.add_child(footer_margin)
	var footer_row := HBoxContainer.new()
	footer_row.add_theme_constant_override("separation", 14)
	footer_margin.add_child(footer_row)
	var footer_status := make_label("●  ПОЛЕ ГОТОВО", 8, C_TEAL)
	footer_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_row.add_child(footer_status)
	footer_row.add_child(make_label("SANDSTONE  ·  44 × 32 м", 8, C_MUTED))
	footer_row.add_child(make_label("30 ОРУЖИЙ  /  10 НОЖЕЙ", 8, C_GOLD))
	footer_row.add_child(make_label("BUILD 0.9.5", 8, C_DIM))

	toast = make_label("", 10, C_TEXT)
	toast.visible = false
	toast.set_anchors_preset(Control.PRESET_TOP_WIDE)
	toast.offset_left = 260.0
	toast.offset_right = -260.0
	toast.offset_top = 84.0
	toast.offset_bottom = 120.0
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast.add_theme_stylebox_override("normal", panel_style(Color("#21150EEF"), C_GOLD))
	toast.z_index = 10
	add_child(toast)

	toast_timer = Timer.new()
	toast_timer.one_shot = true
	toast_timer.wait_time = 2.2
	toast_timer.timeout.connect(_hide_toast)
	add_child(toast_timer)


func build_header() -> void:
	var header := HBoxContainer.new()
	header.anchor_right = 1.0
	header.offset_left = 26.0
	header.offset_top = 18.0
	header.offset_right = -26.0
	header.offset_bottom = 64.0
	header.add_theme_constant_override("separation", 12)
	add_child(header)

	var brand := VBoxContainer.new()
	brand.custom_minimum_size = Vector2(190, 0)
	brand.add_child(make_label("SANDSTONE", 20, C_TEXT))
	brand.add_child(make_label("KS3 // ОПЕРАЦИОННЫЙ БРЕФИНГ", 8, C_GOLD))
	header.add_child(brand)

	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 4)
	nav.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(nav)
	add_nav_button(nav, "overview", "ОПЕРАЦИЯ")
	add_nav_button(nav, "map", "КАРТА")
	add_nav_button(nav, "loadout", "АРСЕНАЛ")
	add_nav_button(nav, "training", "ТРЕНИРОВКА")

	var connection := VBoxContainer.new()
	connection.custom_minimum_size = Vector2(145, 0)
	connection.add_child(make_label("●  СЕТЬ ОНЛАЙН", 8, C_TEAL))
	connection.add_child(make_label("СЕВЕР ЕВРОПЫ · 32 мс", 8, C_MUTED))
	header.add_child(connection)
	header.add_child(
		ui_button("NIKO//ZERO  ›", Callable(func() -> void: show_page("profile")), false)
	)


func add_nav_button(parent: HBoxContainer, id: String, text: String) -> void:
	var button := ui_button(text, Callable(func() -> void: show_page(id)), false)
	button.custom_minimum_size = Vector2(0, 34)
	parent.add_child(button)
	nav_buttons[id] = button


func show_page(id: String) -> void:
	if not pages.has(id):
		id = "overview"
	current_page = id
	for key in nav_buttons:
		var button: Button = nav_buttons[key]
		var active: bool = key == id
		button.add_theme_color_override("font_color", C_GOLD if active else C_MUTED)
		button.add_theme_stylebox_override(
			"normal",
			panel_style(
				Color("#4A2E1B") if active else Color(0, 0, 0, 0),
				C_GOLD if active else Color(0, 0, 0, 0)
			)
		)
	_clear_page()
	call_deferred("_render_page", id)


func _clear_page() -> void:
	for child in page_root.get_children():
		child.queue_free()


func _render_page(id: String) -> void:
	match id:
		"overview":
			build_overview()
		"map":
			build_map_page()
		"loadout":
			build_loadout()
		"training":
			build_training()
		"profile":
			build_profile()
		"settings":
			build_settings()
		_:
			build_overview()
	page_scroll.scroll_vertical = 0


func build_overview() -> void:
	var layout := HBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", 18)
	page_root.add_child(layout)

	var command := VBoxContainer.new()
	command.custom_minimum_size = Vector2(350, 0)
	command.size_flags_vertical = Control.SIZE_EXPAND_FILL
	command.add_theme_constant_override("separation", 10)
	layout.add_child(command)
	command.add_child(make_label("01  //  ОПЕРАЦИЯ SANDSTONE", 9, C_GOLD))
	command.add_child(make_label("ГОРОД\nПЕСКА", 45, C_TEXT))
	command.add_child(
		make_label(
			"Три маршрута. Две точки контроля. Один шанс прочитать поле раньше противника.",
			12,
			C_MUTED
		)
	)
	command.add_child(make_label("ЛОКАЛЬНЫЙ 3D-PLAYABLE SLICE", 8, C_TEAL))
	command.add_child(ui_button("▶  ВОЙТИ В РАУНД", Callable(launch_match), true))
	command.add_child(
		ui_button("ОТКРЫТЬ ПОЛЕВОЙ БРИФИНГ", Callable(func() -> void: show_page("map")), false)
	)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	command.add_child(spacer)
	var command_note := PanelContainer.new()
	command_note.add_theme_stylebox_override("panel", panel_style(Color("#1C100AE0"), C_SAND))
	var note_box := VBoxContainer.new()
	note_box.add_theme_constant_override("separation", 4)
	command_note.add_child(note_box)
	note_box.add_child(make_label("СИСТЕМА ГОТОВА", 8, C_TEAL))
	note_box.add_child(make_label("МЫШЬ  КАМЕРА / ОГОНЬ\nQ / E  ПЕРЕКЛЮЧЕНИЕ АРСЕНАЛА", 9, C_TEXT))
	command.add_child(command_note)

	var intel := VBoxContainer.new()
	intel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	intel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	intel.add_theme_constant_override("separation", 10)
	layout.add_child(intel)

	var briefing := PanelContainer.new()
	briefing.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	briefing.size_flags_vertical = Control.SIZE_EXPAND_FILL
	briefing.custom_minimum_size = Vector2(0, 360)
	briefing.add_theme_stylebox_override("panel", panel_style(Color("#1A0F0AE8"), C_GOLD))
	intel.add_child(briefing)
	var briefing_box := VBoxContainer.new()
	briefing_box.add_theme_constant_override("separation", 7)
	briefing.add_child(briefing_box)
	var hero := make_image(MENU_TEXTURE, 210, Color(0.95, 0.78, 0.56, 0.78))
	hero.size_flags_vertical = Control.SIZE_EXPAND_FILL
	briefing_box.add_child(hero)
	briefing_box.add_child(
		make_label("ЦЕНТРАЛЬНЫЙ ДВОР  ·  WEST MARKET  ·  EAST CITADEL", 9, C_GOLD)
	)
	briefing_box.add_child(make_label("ТЁПЛЫЙ КАМЕНЬ / ХОЛОДНЫЙ СИГНАЛ", 13, C_TEXT))

	var intel_row := HBoxContainer.new()
	intel_row.add_theme_constant_override("separation", 10)
	intel.add_child(intel_row)
	intel_row.add_child(info_card("АРСЕНАЛ", "30", "10 НОЖЕЙ", C_TEAL, "loadout"))
	intel_row.add_child(info_card("ЦЕЛИ", "03", "A / B / TRAINING", C_GOLD, "map"))
	intel_row.add_child(info_card("КАМЕРА", "360°", "MOUSE LOOK", C_GREEN, "training"))


func build_map_page() -> void:
	var title := make_card("SANDSTONE // БРИФИНГ", "КАРТА ЧИТАЕТСЯ ПО СИЛУЭТУ", 0)
	title[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title[1].add_child(
		make_label(
			(
				"Арки открывают sightline, рынок сжимает дистанцию, "
				+ "цитадель даёт высоту. Это собственный procedural blockout."
			),
			10,
			C_MUTED
		)
	)
	page_root.add_child(title[0])

	var image_card := PanelContainer.new()
	image_card.custom_minimum_size = Vector2(0, 280)
	image_card.add_theme_stylebox_override("panel", panel_style(Color("#1A0F0AE8"), C_SAND))
	page_root.add_child(image_card)
	var image_row := HBoxContainer.new()
	image_card.add_child(image_row)
	var map_image := make_image(MENU_TEXTURE, 250, Color(0.92, 0.72, 0.48, 0.78))
	map_image.custom_minimum_size = Vector2(320, 250)
	image_row.add_child(map_image)
	var map_copy := VBoxContainer.new()
	map_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_copy.add_theme_constant_override("separation", 7)
	image_row.add_child(map_copy)
	map_copy.add_child(make_label("SANDSTONE / 44 × 32 м", 19, C_TEXT))
	map_copy.add_child(make_label("WEST MARKET\nCENTRAL COURTYARD\nEAST CITADEL", 12, C_GOLD))
	(
		map_copy
		. add_child(
			make_label(
				"Тёплый sandstone, teal banners, вода как ориентир, две objective-зоны и три читаемых подхода.",
				10,
				C_MUTED
			)
		)
	)
	map_copy.add_child(ui_button("▶  ЗАПУСТИТЬ МАТЧ", Callable(launch_match), true))

	var routes := HBoxContainer.new()
	routes.add_theme_constant_override("separation", 10)
	page_root.add_child(routes)
	for route in [
		["A", "WEST MARKET", "Короткий бой / навесы / цель A", C_TEAL],
		["B", "CENTRAL COURTYARD", "Открытый центр / вода / арка", C_GOLD],
		["C", "EAST CITADEL", "Ступени / балкон / цель B", C_RED]
	]:
		var card := make_card("МАРШРУТ " + route[0], route[1], 150)
		card[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card[1].add_child(make_label(route[2], 10, route[3]))
		routes.add_child(card[0])


func build_loadout() -> void:
	var heading := make_card("ОБОРУДОВАНИЕ", "АРСЕНАЛ // 30 СЛОТОВ", 0)
	heading[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	(
		heading[1]
		. add_child(
			make_label(
				"Каталог доступен в матче: Q/E пролистывают все 30 позиций, 1–0 открывают первые десять.",
				10,
				C_MUTED
			)
		)
	)
	page_root.add_child(heading[0])

	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	page_root.add_child(grid)
	for weapon in Arsenal.WEAPONS:
		var spec: Dictionary = weapon
		grid.add_child(weapon_card(spec))


func build_training() -> void:
	var heading := make_card("ПОДГОТОВКА", "ПРОВЕРКА КАМЕРЫ И ОГНЯ", 0)
	heading[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading[1].add_child(
		make_label(
			(
				"В матче мышь вращает камеру через _input. "
				+ "ЛКМ запускает physics ray query по центру прицела."
			),
			10,
			C_MUTED
		)
	)
	page_root.add_child(heading[0])
	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 10)
	page_root.add_child(controls)
	for item in [
		["W A S D", "движение", C_GREEN],
		["МЫШЬ", "камера 360°", C_TEAL],
		["ЛКМ", "raycast-огонь", C_GOLD],
		["Q / E", "30 слотов", C_RED]
	]:
		var card := make_card(item[0], item[1], 130)
		card[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card[1].add_child(make_label("ГОТОВО", 9, item[2]))
		controls.add_child(card[0])
	page_root.add_child(ui_button("▶  ЗАПУСТИТЬ ТРЕНИРОВКУ", Callable(launch_match), true))


func build_profile() -> void:
	var profile := make_card("ОПЕРАТОР", "NIKO//ZERO", 220)
	profile[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	profile[1].add_child(
		make_label("В ПОЛЕ / ГОТОВ\nРАНГ  ВЕКТОР IV\nТОЧНОСТЬ  67%\nСЕРИЯ  04 ПОБЕД", 13, C_TEXT)
	)
	profile[1].add_child(ui_button("▶  ВОЙТИ В РАУНД", Callable(launch_match), true))
	page_root.add_child(profile[0])


func build_settings() -> void:
	var settings := make_card("СИСТЕМА", "НАСТРОЙКИ ПОЛЯ", 230)
	settings[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings[1].add_child(
		make_label(
			(
				"W A S D     ДВИЖЕНИЕ\nМЫШЬ       ПОВОРОТ КАМЕРЫ\n"
				+ "ЛКМ        ОГОНЬ\nQ / E      СМЕНА ОРУЖИЯ\n"
				+ "1–0        БЫСТРЫЕ СЛОТЫ\nR          ПЕРЕЗАРЯДКА\n"
				+ "ESC        ВЫХОД В МЕНЮ\n\nVIEWPORT   1440 × 900\n"
				+ "MINIMUM    800 × 500"
			),
			11,
			C_TEXT
		)
	)
	page_root.add_child(settings[0])


func info_card(
	kicker: String, value: String, caption: String, color: Color, page: String
) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 94)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", panel_style(Color("#1A0F0DE8"), color))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	card.add_child(box)
	box.add_child(make_label(kicker, 8, C_DIM))
	box.add_child(make_label(value, 24, color))
	box.add_child(make_label(caption, 8, C_MUTED))
	card.gui_input.connect(
		func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed:
				show_page(page)
	)
	return card


func weapon_card(spec: Dictionary) -> PanelContainer:
	var accent: Color = spec["color"] as Color
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 152)
	card.add_theme_stylebox_override("panel", panel_style(Color("#1A0F0C"), accent))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	card.add_child(box)
	box.add_child(make_label(str(spec["category"]), 8, accent))
	box.add_child(make_label(str(spec["name"]), 13, C_TEXT))
	var icon := make_label("◈" if bool(spec["is_knife"]) else "▰", 27, accent)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(icon)
	if bool(spec["is_knife"]):
		box.add_child(make_label("НОЖ  ·  БЛИЖНИЙ БОЙ", 8, C_MUTED))
	else:
		box.add_child(
			make_label(
				(
					"УРОН %02d  ·  МАГАЗИН %02d  ·  CD %.2f"
					% [int(spec["damage"]), int(spec["magazine"]), float(spec["cooldown"])]
				),
				8,
				C_MUTED
			)
		)
	return card


func make_card(kicker: String, title: String, min_height: float) -> Array:
	var panel := PanelContainer.new()
	if min_height > 0.0:
		panel.custom_minimum_size = Vector2(0, min_height)
	panel.add_theme_stylebox_override("panel", panel_style(Color("#1A0F0CE8"), Color("#65452F")))
	var margin := MarginContainer.new()
	set_margins(margin, 14, 14, 12, 12)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	margin.add_child(box)
	box.add_child(make_label(kicker, 8, C_GOLD))
	box.add_child(make_label(title, 17, C_TEXT))
	return [panel, box]


func make_image(texture: Texture2D, min_height: int, tint: Color) -> TextureRect:
	var image := TextureRect.new()
	image.texture = texture
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.custom_minimum_size = Vector2(0, min_height)
	image.modulate = tint
	return image


func launch_match() -> void:
	notify("Открываем 3D-поле Sandstone…")
	call_deferred("_open_match_scene")


func _open_match_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/match.tscn")


func notify(message: String) -> void:
	toast.text = message
	toast.visible = true
	toast_timer.start()


func _hide_toast() -> void:
	if is_instance_valid(toast):
		toast.visible = false


func set_margins(container: MarginContainer, left: int, right: int, top: int, bottom: int) -> void:
	container.add_theme_constant_override("margin_left", left)
	container.add_theme_constant_override("margin_right", right)
	container.add_theme_constant_override("margin_top", top)
	container.add_theme_constant_override("margin_bottom", bottom)


func make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func ui_button(text: String, callback: Callable, accent: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 36)
	button.add_theme_font_size_override("font_size", 9)
	button.add_theme_color_override("font_color", Color("#2A1A11") if accent else C_MUTED)
	button.add_theme_color_override("font_hover_color", Color("#2A1A11") if accent else C_TEXT)
	var normal_fill := C_GOLD if accent else Color("#24150E")
	var hover_fill := Color("#FFD59B") if accent else Color("#4A2F1F")
	button.add_theme_stylebox_override(
		"normal", panel_style(normal_fill, C_GOLD if accent else C_SAND)
	)
	button.add_theme_stylebox_override("hover", panel_style(hover_fill, C_GOLD))
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
