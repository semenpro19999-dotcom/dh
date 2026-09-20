extends Control  # gdlint: ignore=max-public-methods
## KS3 — redesigned native command center for the Sandstone slice.
## The menu is intentionally data-driven and keeps all navigation inside Godot.

const Arsenal = preload("res://scripts/arsenal.gd")
const HERO_TEXTURE = preload("res://assets/ks3-riftfall-hero.jpg")
const WEAPON_TEXTURE = preload("res://assets/fen-9-cobalt.jpg")

const C_BG := Color("#120D0A")
const C_DEEP := Color("#0B0807")
const C_PANEL := Color("#211611")
const C_PANEL_2 := Color("#2C1D15")
const C_SAND := Color("#C58A55")
const C_GOLD := Color("#F0B56F")
const C_TEAL := Color("#68D0C5")
const C_TEXT := Color("#FFF1D5")
const C_MUTED := Color("#C5AA8B")
const C_DIM := Color("#806D5D")
const C_RED := Color("#DF7A68")
const C_GREEN := Color("#86D39D")

var page_host: VBoxContainer
var page_scroll: ScrollContainer
var page_title: Label
var toast: Label
var toast_timer: Timer
var nav_buttons: Dictionary = {}
var current_page := "overview"

var pages := {
	"overview": "Операционный центр",
	"matchmaking": "Запуск операции",
	"map": "Карта Sandstone",
	"loadout": "Арсенал",
	"training": "Подготовка",
	"profile": "Оператор",
	"settings": "Настройки",
}


func _ready() -> void:
	get_window().min_size = Vector2i(800, 500)
	build_shell()
	show_page("overview")


func build_shell() -> void:
	var backdrop := TextureRect.new()
	backdrop.texture = HERO_TEXTURE
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.modulate = Color(0.48, 0.32, 0.22, 0.48)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	var tint := ColorRect.new()
	tint.color = Color(0.05, 0.025, 0.018, 0.78)
	tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tint)

	var shell := HBoxContainer.new()
	shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shell.offset_left = 18.0
	shell.offset_top = 18.0
	shell.offset_right = -18.0
	shell.offset_bottom = -18.0
	shell.add_theme_constant_override("separation", 10)
	add_child(shell)

	var sidebar := PanelContainer.new()
	sidebar.custom_minimum_size = Vector2(238, 0)
	sidebar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sidebar.add_theme_stylebox_override("panel", panel_style(Color("#140D09D9"), Color("#6C4933")))
	shell.add_child(sidebar)
	build_sidebar(sidebar)

	var main_column := VBoxContainer.new()
	main_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_column.add_theme_constant_override("separation", 8)
	shell.add_child(main_column)
	build_header(main_column)

	page_scroll = ScrollContainer.new()
	page_scroll.name = "PageScroll"
	page_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	main_column.add_child(page_scroll)

	var page_margin := MarginContainer.new()
	page_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	set_margins(page_margin, 4, 4, 0, 4)
	page_scroll.add_child(page_margin)
	page_host = VBoxContainer.new()
	page_host.name = "PageHost"
	page_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_host.add_theme_constant_override("separation", 10)
	page_margin.add_child(page_host)

	var footer := make_label(
		"KS3 // SANDSTONE BUILD 0.9.5     ·     СТАТУС СИСТЕМЫ: ОНЛАЙН     ·     СЕВЕР ЕВРОПЫ / 32 мс",
		8,
		C_DIM
	)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	main_column.add_child(footer)

	toast = make_label("", 10, C_TEXT)
	toast.visible = false
	toast.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	toast.offset_left = -314.0
	toast.offset_top = -72.0
	toast.offset_right = -24.0
	toast.offset_bottom = -30.0
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast.add_theme_stylebox_override("normal", panel_style(Color("#2A2118EE"), C_GOLD))
	toast.z_index = 20
	add_child(toast)

	toast_timer = Timer.new()
	toast_timer.one_shot = true
	toast_timer.wait_time = 2.4
	toast_timer.timeout.connect(_hide_toast)
	add_child(toast_timer)


func build_sidebar(sidebar: PanelContainer) -> void:
	var margin := MarginContainer.new()
	set_margins(margin, 14, 14, 14, 12)
	sidebar.add_child(margin)
	var sidebar_scroll := ScrollContainer.new()
	sidebar_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sidebar_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	margin.add_child(sidebar_scroll)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	sidebar_scroll.add_child(box)

	var brand := HBoxContainer.new()
	brand.add_theme_constant_override("separation", 10)
	var mark := make_label("S³", 19, C_GOLD)
	mark.custom_minimum_size = Vector2(42, 38)
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mark.add_theme_stylebox_override("normal", panel_style(Color("#332116"), C_GOLD))
	brand.add_child(mark)
	var brand_copy := VBoxContainer.new()
	brand_copy.add_child(make_label("SANDSTONE", 17, C_TEXT))
	brand_copy.add_child(make_label("KS3 // ПОЛЕВОЙ ЦЕНТР", 8, C_MUTED))
	brand.add_child(brand_copy)
	box.add_child(brand)

	var rule := ColorRect.new()
	rule.color = C_SAND
	rule.custom_minimum_size = Vector2(0, 1)
	box.add_child(rule)
	box.add_child(make_label("", 5, C_DIM))
	box.add_child(make_label("●  СЕТЬ ОНЛАЙН     СЕЗОН 03", 8, C_TEAL))
	box.add_child(make_label("", 8, C_DIM))

	var groups: Array = [
		[
			"ОПЕРАЦИИ",
			[
				["overview", "▦", "Центр"],
				["matchmaking", "▶", "Играть"],
				["map", "⌁", "Карта Sandstone"]
			]
		],
		["АРСЕНАЛ", [["loadout", "▣", "30 видов оружия"], ["training", "⊙", "Тренировка"]]],
		["СИСТЕМА", [["profile", "◉", "Оператор"], ["settings", "⚙", "Настройки"]]],
	]
	for group in groups:
		box.add_child(make_label(group[0], 8, C_DIM))
		for item in group[1]:
			var page_id: String = str(item[0])
			var nav := nav_button(page_id, str(item[1]), str(item[2]))
			box.add_child(nav)
		box.add_child(make_label("", 3, C_DIM))

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)

	var mission := PanelContainer.new()
	mission.custom_minimum_size = Vector2(0, 112)
	mission.add_theme_stylebox_override("panel", panel_style(Color("#332117"), C_SAND))
	var mission_box := VBoxContainer.new()
	mission_box.add_theme_constant_override("separation", 4)
	mission.add_child(mission_box)
	mission_box.add_child(make_label("АКТИВНАЯ ОПЕРАЦИЯ", 8, C_GOLD))
	mission_box.add_child(make_label("SANDSTONE\nРАЗОМКНУТЬ ЦЕНТР", 15, C_TEXT))
	mission_box.add_child(make_label("3 цели · 03:00 · 2 объекта", 8, C_MUTED))
	mission_box.add_child(
		ui_button("ОТКРЫТЬ БРИФИНГ", Callable(func() -> void: show_page("map")), false)
	)
	box.add_child(mission)

	var profile := Button.new()
	profile.text = "●  NIKO//ZERO\n    В ПОЛЕ / ГОТОВ"
	profile.alignment = HORIZONTAL_ALIGNMENT_LEFT
	profile.custom_minimum_size = Vector2(0, 44)
	profile.add_theme_font_size_override("font_size", 10)
	profile.add_theme_color_override("font_color", C_TEXT)
	profile.add_theme_stylebox_override("normal", panel_style(Color("#1D130E"), Color("#4D3426")))
	profile.add_theme_stylebox_override("hover", panel_style(Color("#392419"), C_GOLD))
	profile.pressed.connect(func() -> void: show_page("profile"))
	box.add_child(profile)


func build_header(main_column: VBoxContainer) -> void:
	var header := PanelContainer.new()
	header.custom_minimum_size = Vector2(0, 66)
	header.add_theme_stylebox_override("panel", panel_style(Color("#130C09DD"), Color("#6C4933")))
	main_column.add_child(header)
	var margin := MarginContainer.new()
	set_margins(margin, 18, 14, 10, 10)
	header.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)
	page_title = make_label("SANDSTONE / ОПЕРАЦИОННЫЙ ЦЕНТР", 10, C_TEXT)
	page_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(page_title)
	row.add_child(make_label("СЕВЕР ЕВРОПЫ\n32 мс", 8, C_TEAL))
	row.add_child(ui_button("◌", Callable(func() -> void: notify("Нет новых сообщений")), false))
	row.add_child(ui_button("niko//zero  ›", Callable(func() -> void: show_page("profile")), false))


func nav_button(id: String, icon: String, label: String) -> Button:
	var button := Button.new()
	button.text = icon + "   " + label
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(0, 34)
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_color_override("font_color", C_MUTED)
	button.add_theme_color_override("font_hover_color", C_TEXT)
	button.add_theme_stylebox_override("normal", panel_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))
	button.add_theme_stylebox_override("hover", panel_style(Color("#382319"), Color("#6B4933")))
	button.pressed.connect(func() -> void: show_page(id))
	nav_buttons[id] = button
	return button


func show_page(id: String) -> void:
	if not pages.has(id):
		id = "overview"
	current_page = id
	page_title.text = "SANDSTONE / " + str(pages[id]).to_upper()
	for key in nav_buttons:
		var button: Button = nav_buttons[key]
		var active: bool = key == id
		button.add_theme_color_override("font_color", C_GOLD if active else C_MUTED)
		button.add_theme_stylebox_override(
			"normal",
			panel_style(
				Color("#382319") if active else Color(0, 0, 0, 0),
				C_GOLD if active else Color(0, 0, 0, 0)
			)
		)
	_clear_page()
	call_deferred("_render_page", id)


func _clear_page() -> void:
	for child in page_host.get_children():
		child.queue_free()


func _render_page(id: String) -> void:
	match id:
		"overview":
			build_overview()
		"matchmaking":
			build_matchmaking()
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
	page_heading(
		"ОПЕРАЦИОННЫЙ ЦЕНТР",
		"ГОРОД ПЕСКА",
		"Sandstone — новый локальный полигон KS3. Изучи маршруты, выбери оружие и зайди в раунд."
	)
	var hero := PanelContainer.new()
	hero.custom_minimum_size = Vector2(0, 270)
	hero.add_theme_stylebox_override("panel", panel_style(Color("#1A100BDD"), C_SAND))
	var hero_row := HBoxContainer.new()
	hero.add_child(hero_row)
	var hero_image := make_image(HERO_TEXTURE, 248, Color(0.78, 0.59, 0.42, 0.86))
	hero_image.custom_minimum_size = Vector2(250, 248)
	hero_row.add_child(hero_image)
	var hero_copy := VBoxContainer.new()
	hero_copy.add_theme_constant_override("separation", 8)
	hero_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_row.add_child(hero_copy)
	hero_copy.add_child(make_label("—  СЕЗОН 03  //  ПОЛЕВОЙ БРИФИНГ", 9, C_GOLD))
	hero_copy.add_child(make_label("SANDSTONE", 31, C_TEXT))
	hero_copy.add_child(
		make_label(
			(
				"Арки, рынки, башни и длинные линии между стенами. "
				+ "Карта построена вокруг трёх маршрутов и центральной площади."
			),
			11,
			C_MUTED
		)
	)
	var hero_buttons := HBoxContainer.new()
	hero_buttons.add_theme_constant_override("separation", 8)
	hero_buttons.add_child(ui_button("▶  НАЙТИ МАТЧ", Callable(launch_match), true))
	hero_buttons.add_child(
		ui_button("БРИФИНГ КАРТЫ", Callable(func() -> void: show_page("map")), false)
	)
	hero_copy.add_child(hero_buttons)
	hero_copy.add_child(make_label("3 ЦЕЛИ     2 ОБЪЕКТА     30 ОРУЖИЙ     10 НОЖЕЙ", 8, C_TEAL))
	page_host.add_child(hero)

	var metrics := HBoxContainer.new()
	metrics.add_theme_constant_override("separation", 10)
	metrics.add_child(stat_card("ПОЛЕ", "SANDSTONE", "ГОРОД-КРЕПОСТ", C_GOLD))
	metrics.add_child(stat_card("АРСЕНАЛ", "30", "10 НОЖЕЙ В КАТАЛОГЕ", C_TEAL))
	metrics.add_child(stat_card("КАМЕРА", "360°", "МЫШЬ / FPS ОБЗОР", C_GREEN))
	page_host.add_child(metrics)

	var lower := HBoxContainer.new()
	lower.add_theme_constant_override("separation", 10)
	var brief := make_card("СЕГОДНЯ НА ЛИНИИ", "Короткий план", 170)
	brief[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	(
		brief[1]
		. add_child(
			make_label(
				"01  ВОЗЬМИ ЦЕНТРАЛЬНЫЙ ДВОР\n02  ПРОВЕРЬ ЗАПАДНЫЙ РЫНОК\n03  НЕ ОТДАВАЙ ВОСТОЧНУЮ ЦИТАДЕЛЬ",
				10,
				C_TEXT
			)
		)
	)
	brief[1].add_child(
		ui_button("ПОКАЗАТЬ МАРШРУТЫ  →", Callable(func() -> void: show_page("map")), false)
	)
	lower.add_child(brief[0])
	var loadout := make_card("БЫСТРЫЙ ДОСТУП", "Снаряжение", 170)
	loadout[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	loadout[1].add_child(make_label("FEN-9 COBALT\nVANTA EDGE\n+ 28 СЛОТОВ АРСЕНАЛА", 10, C_TEXT))
	loadout[1].add_child(
		ui_button("ОТКРЫТЬ АРСЕНАЛ  →", Callable(func() -> void: show_page("loadout")), false)
	)
	lower.add_child(loadout[0])
	page_host.add_child(lower)


func build_matchmaking() -> void:
	page_heading("ОПЕРАЦИИ", "ЗАПУСК МАТЧА", "Быстрый вход в локальный 3D-срез Sandstone.")
	var launch := make_card("ВЫБРАННАЯ ОПЕРАЦИЯ", "SANDSTONE // РЕЙТИНГ 5×5", 250)
	launch[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	launch[1].add_child(make_image(HERO_TEXTURE, 130, Color(0.72, 0.48, 0.32, 0.72)))
	launch[1].add_child(
		make_label(
			"ГОРОД-КРЕПОСТЬ     44 × 32 м\nТРЁХЛУЧЕВАЯ СХЕМА     ЗАПАДНЫЙ РЫНОК / ЦЕНТР / ЦИТАДЕЛЬ",
			9,
			C_MUTED
		)
	)
	launch[1].add_child(ui_button("▶  ВОЙТИ В SANDSTONE", Callable(launch_match), true))
	page_host.add_child(launch[0])

	var modes := HBoxContainer.new()
	modes.add_theme_constant_override("separation", 10)
	for mode in ["РЕЙТИНГ 5×5", "КАЗУАЛ", "ДУЭЛЬ"]:
		var card := make_card("РЕЖИМ", mode, 130)
		card[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card[1].add_child(make_label("ЛОКАЛЬНЫЙ ПРОТОТИП\n3 цели · 1 игрок", 9, C_MUTED))
		card[1].add_child(
			ui_button(
				"ВЫБРАТЬ", Callable(func() -> void: notify(mode + " выбран")), mode == "РЕЙТИНГ 5×5"
			)
		)
		modes.add_child(card[0])
	page_host.add_child(modes)


func build_map_page() -> void:
	page_heading(
		"КАРТА // SANDSTONE",
		"ПОЛЕВОЙ БРИФИНГ",
		"Референсная карта-песчаник: тесные линии, открытый центр и вертикальный контроль."
	)
	var map_card := PanelContainer.new()
	map_card.custom_minimum_size = Vector2(0, 270)
	map_card.add_theme_stylebox_override("panel", panel_style(Color("#1A100DDD"), C_SAND))
	var row := HBoxContainer.new()
	map_card.add_child(row)
	var image := make_image(HERO_TEXTURE, 248, Color(0.82, 0.58, 0.38, 0.86))
	image.custom_minimum_size = Vector2(250, 248)
	row.add_child(image)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 6)
	row.add_child(copy)
	copy.add_child(
		make_label("01  WEST MARKET     02  CENTRAL COURTYARD     03  EAST CITADEL", 8, C_GOLD)
	)
	copy.add_child(make_label("Sandstone / Разомкнутый центр", 22, C_TEXT))
	copy.add_child(
		make_label(
			(
				"Песчаниковые стены дают тёплую силуэтную форму, бирюзовые ткани "
				+ "и вода создают контрастные ориентиры. Арки разделяют зоны, "
				+ "но оставляют читаемые прострелы."
			),
			10,
			C_MUTED
		)
	)
	copy.add_child(make_label("РАЗМЕР 44 × 32 м     СТАРТ ЮГ     ОБЪЕКТИВЫ A / B", 9, C_TEAL))
	copy.add_child(ui_button("ВЫЙТИ НА ПОЛЕ  →", Callable(launch_match), true))
	page_host.add_child(map_card)

	var routes := HBoxContainer.new()
	routes.add_theme_constant_override("separation", 10)
	var west := make_card("МАРШРУТ A", "ЗАПАДНЫЙ РЫНОК", 190)
	west[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	west[1].add_child(
		make_label("Тесный ближний бой\nНавесы и низкие стены\nЦель A / боковой обход", 10, C_TEXT)
	)
	routes.add_child(west[0])
	var center := make_card("МАРШРУТ B", "ЦЕНТРАЛЬНЫЙ ДВОР", 190)
	center[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center[1].add_child(
		make_label(
			"Открытая площадь\nДлинная линия через арку\nВода как визуальный якорь", 10, C_TEXT
		)
	)
	routes.add_child(center[0])
	var east := make_card("МАРШРУТ C", "ВОСТОЧНАЯ ЦИТАДЕЛЬ", 190)
	east[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	east[1].add_child(
		make_label("Высота и ступени\nКрепость с балконом\nЦель B / дальний контроль", 10, C_TEXT)
	)
	routes.add_child(east[0])
	page_host.add_child(routes)

	var principles := make_card("LEVEL DESIGN NOTES", "Что взято из 30 референсов", 150)
	principles[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	principles[1].add_child(
		make_label(
			(
				"КОНТРАСТ: солнечная охра и глубокие тени переулков\n"
				+ "СИЛУЭТ: арки, башни, навесы и песчаниковые фасады\n"
				+ "ИГРА: три маршрута, короткие chokepoint'ы и читаемые высоты"
			),
			10,
			C_MUTED
		)
	)
	page_host.add_child(principles[0])


func build_loadout() -> void:
	page_heading(
		"АРСЕНАЛ",
		"30 ВИДОВ ОРУЖИЯ",
		"20 огнестрельных платформ и 10 ножей уже заведены в игровой каталог и доступны через Q/E."
	)
	var banner := make_card("КОНТРОЛЬ СНАРЯЖЕНИЯ", "FEN-9 COBALT // СЛОТ 01", 170)
	banner[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var banner_row := HBoxContainer.new()
	banner[1].add_child(banner_row)
	var banner_image := make_image(WEAPON_TEXTURE, 120, Color(0.66, 0.86, 0.82, 0.82))
	banner_image.custom_minimum_size = Vector2(220, 120)
	banner_row.add_child(banner_image)
	var banner_copy := VBoxContainer.new()
	banner_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	banner_copy.add_child(make_label("20 ОГНЕСТРЕЛЬНЫХ     10 НОЖЕЙ     30 СЛОТОВ", 10, C_TEAL))
	(
		banner_copy
		. add_child(
			make_label(
				"Q / E переключают каталог в матче. Клавиши 1–0 дают быстрый доступ к первым десяти слотам.",
				10,
				C_MUTED
			)
		)
	)
	banner_copy.add_child(ui_button("ВОЙТИ В ТРЕНИРОВКУ  →", Callable(launch_match), true))
	banner_row.add_child(banner_copy)
	page_host.add_child(banner[0])

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_host.add_child(grid)
	for weapon in Arsenal.WEAPONS:
		var spec: Dictionary = weapon
		grid.add_child(weapon_card(spec))


func build_training() -> void:
	page_heading(
		"ПОДГОТОВКА",
		"ПОЛЕВОЙ ТРЕНАЖЁР",
		"Проверь поворот камеры, движение, raycast-стрельбу и весь каталог оружия."
	)
	var camera_card := make_card("FPS CAMERA", "ПОВОРОТ КАМЕРЫ 360°", 190)
	camera_card[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	camera_card[1].add_child(
		make_label(
			(
				"МЫШЬ X  →  ПОВОРОТ ПО ГОРИЗОНТУ\n"
				+ "МЫШЬ Y  →  НАКЛОН ГОЛОВЫ\nЛКМ  →  RAYCAST-ОГОНЬ\n"
				+ "ESC  →  ВЕРНУТЬСЯ В ЦЕНТР"
			),
			10,
			C_TEXT
		)
	)
	camera_card[1].add_child(ui_button("ЗАПУСТИТЬ ТРЕНИРОВКУ", Callable(launch_match), true))
	page_host.add_child(camera_card[0])
	var checks := HBoxContainer.new()
	checks.add_theme_constant_override("separation", 10)
	for check in [
		["КОЛЛИЗИИ", "CharacterBody3D + укрытия", C_GREEN],
		["АРСЕНАЛ", "30 data-driven слотов", C_TEAL],
		["КАРТА", "Sandstone blockout", C_GOLD]
	]:
		var card := make_card("ГОТОВО", check[0], 125)
		card[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card[1].add_child(make_label(check[1], 9, check[2]))
		checks.add_child(card[0])
	page_host.add_child(checks)


func build_profile() -> void:
	page_heading("ОПЕРАТОР", "NIKO//ZERO", "Полевой профиль и текущая готовность к Sandstone.")
	var profile := make_card("СТАТУС", "ОПЕРАТОР ГОТОВ", 180)
	profile[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	profile[1].add_child(
		make_label(
			(
				"РАНГ  ВЕКТОР IV     СЕРИЯ 04 ПОБЕД\n"
				+ "ТОЧНОСТЬ  67%       ОБЪЕКТЫ  18\n"
				+ "ПРОФИЛЬ  ОТКРЫТЫЙ ТЕСТЕР 0.9.5"
			),
			11,
			C_TEXT
		)
	)
	profile[1].add_child(ui_button("ПОДГОТОВИТЬСЯ К РАУНДУ", Callable(launch_match), true))
	page_host.add_child(profile[0])

	var notes := make_card("ПРОТОКОЛ", "Последние изменения", 170)
	notes[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	notes[1].add_child(
		make_label(
			(
				"+ Sandstone: арки, рынки, цитадель, две зоны\n"
				+ "+ Арсенал: 30 видов, включая 10 ножей\n"
				+ "+ Камера: mouse look с ограничением вертикального угла\n"
				+ "+ HUD: имя оружия, слот, патроны и цели"
			),
			10,
			C_MUTED
		)
	)
	page_host.add_child(notes[0])


func build_settings() -> void:
	page_heading(
		"СИСТЕМА",
		"НАСТРОЙКИ",
		"Быстрые параметры прототипа. Базовый viewport 1440×900, минимум 800×500."
	)
	var controls := make_card("УПРАВЛЕНИЕ", "ПОЛЕВЫЕ КОМАНДЫ", 230)
	controls[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls[1].add_child(
		make_label(
			(
				"W A S D     ДВИЖЕНИЕ\nМЫШЬ       ПОВОРОТ КАМЕРЫ\n"
				+ "ЛКМ        ОГОНЬ\nQ / E      СМЕНА ОРУЖИЯ\n"
				+ "1–0        БЫСТРЫЕ СЛОТЫ\nR  ПЕРЕЗАРЯДКА\n"
				+ "ESC        ВЫХОД В МЕНЮ"
			),
			10,
			C_TEXT
		)
	)
	controls[1].add_child(
		ui_button(
			"СБРОСИТЬ ПОДСКАЗКИ", Callable(func() -> void: notify("Подсказки восстановлены")), false
		)
	)
	page_host.add_child(controls[0])

	var runtime := make_card("RUNTIME", "GODOT 4.5+ NATIVE", 150)
	runtime[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	runtime[1].add_child(
		make_label(
			(
				"Единственный runtime: Godot\nСцена меню: Control\n"
				+ "Сцена матча: Node3D\nRenderer: GL Compatibility"
			),
			10,
			C_MUTED
		)
	)
	page_host.add_child(runtime[0])


func page_heading(kicker: String, title: String, description: String) -> void:
	page_host.add_child(make_label(kicker, 8, C_GOLD))
	page_host.add_child(make_label(title, 25, C_TEXT))
	page_host.add_child(make_label(description, 10, C_MUTED))


func make_card(kicker: String, title: String, min_height: float = 0.0) -> Array:
	var panel := PanelContainer.new()
	if min_height > 0.0:
		panel.custom_minimum_size = Vector2(0, min_height)
	panel.add_theme_stylebox_override("panel", panel_style(Color("#1B100CDD"), Color("#60412F")))
	var margin := MarginContainer.new()
	set_margins(margin, 14, 14, 12, 12)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	margin.add_child(box)
	box.add_child(make_label(kicker, 8, C_GOLD))
	box.add_child(make_label(title, 16, C_TEXT))
	return [panel, box]


func stat_card(kicker: String, value: String, caption: String, color: Color) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 86)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", panel_style(Color("#20140E"), color))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	card.add_child(box)
	box.add_child(make_label(kicker, 8, C_DIM))
	box.add_child(make_label(value, 21, color))
	box.add_child(make_label(caption, 8, C_MUTED))
	return card


func weapon_card(spec: Dictionary) -> PanelContainer:
	var accent: Color = spec["color"] as Color
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 156)
	card.add_theme_stylebox_override("panel", panel_style(Color("#1A100D"), accent))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	card.add_child(box)
	var category: String = str(spec["category"])
	var name: String = str(spec["name"])
	box.add_child(
		make_label(
			category + "     " + ("НОЖ" if bool(spec["is_knife"]) else "ОГНЕСТРЕЛ"), 8, accent
		)
	)
	box.add_child(make_label(name, 13, C_TEXT))
	var silhouette := make_label("◈" if bool(spec["is_knife"]) else "▰", 28, accent)
	silhouette.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(silhouette)
	if bool(spec["is_knife"]):
		box.add_child(make_label("БЛИЖНИЙ БОЙ     УРОН 100", 8, C_MUTED))
	else:
		box.add_child(
			make_label(
				(
					"УРОН %02d     МАГАЗИН %02d     CD %.2f"
					% [int(spec["damage"]), int(spec["magazine"]), float(spec["cooldown"])]
				),
				8,
				C_MUTED
			)
		)
	return card


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
	button.custom_minimum_size = Vector2(0, 34)
	button.add_theme_font_size_override("font_size", 9)
	button.add_theme_color_override("font_color", Color("#2A1A11") if accent else C_MUTED)
	button.add_theme_color_override("font_hover_color", Color("#2A1A11") if accent else C_TEXT)
	var normal_fill := C_GOLD if accent else Color("#2A1A11")
	var hover_fill := Color("#FFD49B") if accent else Color("#483022")
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
