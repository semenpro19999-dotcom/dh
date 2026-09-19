extends Control
## KS3 Command Center — Godot 4.5+ UI vertical slice.
## The UI is built with native Control nodes so the project stays editable in the Godot editor.

const C_BG := Color("#090E14")
const C_DEEP := Color("#070B10")
const C_PANEL := Color("#101820")
const C_PANEL_2 := Color("#14212A")
const C_LINE := Color("#27373E")
const C_TEXT := Color("#ECF3F2")
const C_MUTED := Color("#82959A")
const C_DIM := Color("#5E747B")
const C_CYAN := Color("#73DDD7")
const C_AMBER := Color("#F1B66E")
const C_PURPLE := Color("#AA8EEA")
const C_GREEN := Color("#72C58D")
const C_RED := Color("#EF7773")

var page_host: VBoxContainer
var page_title: Label
var toast: Label
var toast_timer: Timer
var queue_timer: Timer
var queue_seconds := 0
var searching := false
var nav_buttons: Dictionary = {}
var current_page := "overview"

var pages := {
	"overview": "Overview",
	"matchmaking": "Matchmaking",
	"loadout": "Inventory",
	"case-lab": "Case Lab",
	"progression": "Progression",
	"training": "Training",
	"field-hud": "Field HUD",
	"patch-notes": "Patch notes",
	"profile": "Operator profile",
}

func _ready() -> void:
	build_shell()
	show_page("overview")

func build_shell() -> void:
	var background := ColorRect.new()
	background.color = C_BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var shell := HBoxContainer.new()
	shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shell.add_theme_constant_override("separation", 0)
	add_child(shell)

	var sidebar := PanelContainer.new()
	sidebar.custom_minimum_size = Vector2(252, 0)
	sidebar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sidebar.add_theme_stylebox_override("panel", panel_style(Color("#0C141C"), Color("#182831")))
	shell.add_child(sidebar)
	build_sidebar(sidebar)

	var main_column := VBoxContainer.new()
	main_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_column.add_theme_constant_override("separation", 0)
	shell.add_child(main_column)
	build_header(main_column)

	var scroll := ScrollContainer.new()
	scroll.name = "PageScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_column.add_child(scroll)

	var page_margin := MarginContainer.new()
	page_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_margin.add_theme_constant_override("margin_left", 39)
	page_margin.add_theme_constant_override("margin_right", 39)
	page_margin.add_theme_constant_override("margin_top", 20)
	page_margin.add_theme_constant_override("margin_bottom", 20)
	scroll.add_child(page_margin)
	page_host = VBoxContainer.new()
	page_host.name = "PageHost"
	page_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_host.add_theme_constant_override("separation", 16)
	page_margin.add_child(page_host)

	toast = make_label("", 10, C_TEXT)
	toast.visible = false
	toast.position = Vector2(24, 24)
	toast.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	toast.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	toast.grow_vertical = Control.GROW_DIRECTION_BEGIN
	toast.custom_minimum_size = Vector2(280, 42)
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast.add_theme_stylebox_override("normal", panel_style(Color("#16282C"), C_CYAN))
	toast.z_index = 20
	add_child(toast)

	toast_timer = Timer.new()
	toast_timer.one_shot = true
	toast_timer.wait_time = 2.8
	toast_timer.timeout.connect(func() -> void: toast.visible = false)
	add_child(toast_timer)

	queue_timer = Timer.new()
	queue_timer.wait_time = 1.0
	queue_timer.timeout.connect(_on_queue_tick)
	add_child(queue_timer)

func build_sidebar(sidebar: PanelContainer) -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 27)
	margin.add_theme_constant_override("margin_bottom", 16)
	sidebar.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	margin.add_child(box)

	var brand := HBoxContainer.new()
	brand.add_theme_constant_override("separation", 12)
	var mark := make_label("K S ³", 17, C_CYAN)
	mark.custom_minimum_size = Vector2(35, 32)
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mark.add_theme_stylebox_override("normal", panel_style(Color("#101F25"), C_CYAN))
	brand.add_child(mark)
	var brand_copy := VBoxContainer.new()
	brand_copy.add_child(make_label("KS3", 19, C_TEXT))
	brand_copy.add_child(make_label("COMMAND CENTER", 8, C_DIM))
	brand.add_child(brand_copy)
	box.add_child(brand)
	box.add_child(make_label("", 10, C_MUTED))

	var network := make_label("●  NETWORK ONLINE                         0.9.4", 8, C_MUTED)
	network.add_theme_stylebox_override("normal", panel_style(Color("#0B151C"), C_LINE))
	box.add_child(network)
	box.add_child(make_label("", 6, C_MUTED))

	var groups := [
		["OPERATIONS", [["overview", "▦", "Overview"], ["matchmaking", "◎", "Play"], ["loadout", "▣", "Inventory"], ["case-lab", "◇", "Cases"], ["store", "▤", "Store"]]],
		["SQUAD", [["profile", "◉", "Profile"], ["friends", "＋", "Friends"], ["training", "⊙", "Training"]]],
		["INTEL", [["progression", "⌁", "Progression"], ["field-hud", "⊕", "Field HUD"], ["patch-notes", "▤", "Patch notes"]]],
	]
	for group in groups:
		box.add_child(make_label(group[0], 8, C_DIM))
		for entry in group[1]:
			var nav := nav_button(entry[0], entry[1], entry[2])
			box.add_child(nav)
			box.add_child(make_label("", 1, C_MUTED))
		box.add_child(make_label("", 5, C_MUTED))

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)

	var season := PanelContainer.new()
	season.custom_minimum_size = Vector2(0, 100)
	season.add_theme_stylebox_override("panel", panel_style(Color("#16343A"), Color("#315D60")))
	var season_box := VBoxContainer.new()
	season_box.add_theme_constant_override("separation", 7)
	season.add_child(season_box)
	season_box.add_child(make_label("SEASON 03                         LIVE", 8, C_CYAN))
	season_box.add_child(make_label("RIFT\nPROTOCOL", 17, C_TEXT))
	var season_bar := ProgressBar.new()
	season_bar.value = 68
	season_bar.show_percentage = false
	season_bar.custom_minimum_size = Vector2(0, 3)
	season_bar.add_theme_stylebox_override("background", panel_style(Color("#0B1A1D"), Color("#0B1A1D")))
	season_bar.add_theme_stylebox_override("fill", panel_style(C_CYAN, C_CYAN))
	season_box.add_child(season_bar)
	season_box.add_child(make_label("68% complete                     24d 08h", 8, C_MUTED))
	box.add_child(season)

	var settings := nav_button("settings", "⚙", "Settings")
	box.add_child(settings)
	var profile := Button.new()
	profile.text = "●  niko//zero\n    ONLINE"
	profile.alignment = HORIZONTAL_ALIGNMENT_LEFT
	profile.custom_minimum_size = Vector2(0, 38)
	profile.add_theme_font_size_override("font_size", 11)
	profile.add_theme_color_override("font_color", C_TEXT)
	profile.add_theme_stylebox_override("normal", panel_style(Color("#0D171E"), C_LINE))
	profile.add_theme_stylebox_override("hover", panel_style(Color("#15272B"), C_CYAN))
	profile.pressed.connect(func() -> void: show_page("profile"))
	box.add_child(profile)

func build_header(main_column: VBoxContainer) -> void:
	var header := PanelContainer.new()
	header.custom_minimum_size = Vector2(0, 76)
	header.add_theme_stylebox_override("panel", panel_style(Color("#0A1118"), Color("#192A32")))
	main_column.add_child(header)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 39)
	margin.add_theme_constant_override("margin_right", 39)
	header.add_child(margin)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 13)
	margin.add_child(row)
	page_title = make_label("COMMAND CENTER / OVERVIEW", 9, C_MUTED)
	page_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(page_title)
	var region := make_label("●  EU NORTH     32 ms", 8, C_CYAN)
	region.add_theme_stylebox_override("normal", panel_style(Color("#0E1B21"), Color("#25434A")))
	row.add_child(region)
	var notify := ui_button("◌", Callable(), false)
	notify.custom_minimum_size = Vector2(34, 34)
	row.add_child(notify)
	var gear := ui_button("⚙", Callable(open_settings), false)
	gear.custom_minimum_size = Vector2(34, 34)
	row.add_child(gear)
	var profile := ui_button("niko//zero   2,480  ›", Callable(func() -> void: show_page("profile")), false)
	profile.custom_minimum_size = Vector2(155, 34)
	row.add_child(profile)

func nav_button(id: String, icon: String, label: String) -> Button:
	var b := Button.new()
	b.text = icon + "   " + label
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(0, 34)
	b.add_theme_font_size_override("font_size", 11)
	b.add_theme_color_override("font_color", C_MUTED)
	b.add_theme_color_override("font_hover_color", C_TEXT)
	b.add_theme_stylebox_override("normal", panel_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))
	b.add_theme_stylebox_override("hover", panel_style(Color("#112228"), Color("#24434A")))
	b.pressed.connect(func() -> void:
		if id == "settings":
			open_settings()
		elif id == "store":
			show_page("case-lab")
		elif id == "friends":
			notify("Friends panel opened")
		else:
			show_page(id)
	)
	nav_buttons[id] = b
	return b

func show_page(id: String) -> void:
	current_page = id
	page_title.text = "COMMAND CENTER / " + pages.get(id, "OVERVIEW").to_upper()
	for key in nav_buttons:
		var button: Button = nav_buttons[key]
		var active: bool = String(key) == id
		button.add_theme_color_override("font_color", C_CYAN if active else C_MUTED)
		button.add_theme_stylebox_override("normal", panel_style(Color("#12272B") if active else Color(0, 0, 0, 0), C_CYAN if active else Color(0, 0, 0, 0)))
	for child in page_host.get_children():
		child.free()
	match id:
		"overview": build_overview()
		"matchmaking": build_matchmaking()
		"loadout": build_inventory()
		"case-lab": build_case_lab()
		"progression": build_progression()
		"training": build_training()
		"field-hud": build_field_hud()
		"patch-notes": build_patch_notes()
		"profile": build_profile()

func build_overview() -> void:
	var intro := HBoxContainer.new()
	intro.custom_minimum_size = Vector2(0, 24)
	intro.add_child(make_label("COMMAND DECK // LIVE OPERATIONS", 8, C_CYAN))
	var sync := make_label("SEASON 03     LAST SYNC 14:32:08 UTC", 8, C_DIM)
	sync.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sync.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	intro.add_child(sync)
	page_host.add_child(intro)

	page_host.add_child(hero_panel())

	var quick := HBoxContainer.new()
	quick.add_theme_constant_override("separation", 12)
	page_host.add_child(quick)
	var play := make_card("PLAY // RANKED", "Find a match", 166)
	play[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	play[1].add_child(make_label("5v5 · first to 13 · overtime enabled", 9, C_MUTED))
	play[1].add_child(make_label("RIFT / FALL     EU NORTH · 32 ms", 9, C_CYAN))
	play[1].add_child(ui_button("▶  PLAY RANKED", Callable(func() -> void: show_page("matchmaking")), true))
	quick.add_child(play[0])

	var rank := make_card("YOUR SIGNAL", "VECTOR IV", 166)
	rank[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rank[1].add_child(make_label("2,480 RP        +124 THIS WEEK", 9, C_CYAN))
	var progress := ProgressBar.new()
	progress.value = 62
	progress.show_percentage = false
	progress.custom_minimum_size = Vector2(0, 5)
	progress.add_theme_stylebox_override("background", panel_style(Color("#24343A"), Color("#24343A")))
	progress.add_theme_stylebox_override("fill", panel_style(C_CYAN, C_CYAN))
	rank[1].add_child(progress)
	rank[1].add_child(make_label("183 RP TO VECTOR V", 8, C_MUTED))
	quick.add_child(rank[0])

	var squad := make_card("FIRETEAM // 4 ONLINE", "Your squad", 166)
	squad[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_squad_row(squad[1], "niko//zero", "SHOTCALLER", "IN MENU")
	add_squad_row(squad[1], "mara.v", "ENTRY", "IN MATCH")
	add_squad_row(squad[1], "k0met", "ANCHOR", "IN MENU")
	quick.add_child(squad[0])

	var feed := HBoxContainer.new()
	feed.add_theme_constant_override("separation", 12)
	page_host.add_child(feed)
	var ops := make_card("FIELD INTEL // 01", "Active operations", 170)
	ops[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_operation(ops[1], "01", "Controlled demolition", "Destroy 2 reinforced panels.", "+2,500 XP", C_CYAN, "72%")
	add_operation(ops[1], "02", "Quiet entry", "Plant the Key without a sound cue.", "+1,200 XP", C_AMBER, "38%")
	feed.add_child(ops[0])

	var season := make_card("SIGNAL // NEXT", "What matters now", 170)
	season[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	season[1].add_child(make_label("MAP ROTATION", 8, C_DIM))
	season[1].add_child(make_label("RIFT / FALL  ·  OVERCAST", 10, C_TEXT))
	season[1].add_child(make_label("NEXT UNLOCK", 8, C_DIM))
	season[1].add_child(make_label("RIFT // AFTERGLOW CASE  ·  LVL 42", 9, C_PURPLE))
	feed.add_child(season[0])

func hero_panel() -> PanelContainer:
	var hero := PanelContainer.new()
	hero.custom_minimum_size = Vector2(0, 300)
	hero.add_theme_stylebox_override("panel", panel_style(Color("#10242B"), Color("#31585C")))
	var layer := Control.new()
	layer.custom_minimum_size = Vector2(0, 300)
	hero.add_child(layer)
	var image := TextureRect.new()
	image.texture = load("res://assets/ks3-riftfall-hero.jpg")
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.modulate = Color(0.52, 0.76, 0.77, 0.7)
	layer.add_child(image)
	var shade := ColorRect.new()
	shade.color = Color(0.03, 0.08, 0.10, 0.72)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(shade)
	var copy := VBoxContainer.new()
	copy.position = Vector2(44, 27)
	copy.size = Vector2(500, 235)
	copy.add_theme_constant_override("separation", 10)
	layer.add_child(copy)
	copy.add_child(make_label("—  SEASON 03  //  RIFT PROTOCOL", 9, C_CYAN))
	copy.add_child(make_label("Precision\nover force.", 45, C_TEXT))
	copy.add_child(make_label("Read the room. Break the line. Every round is a system waiting to be solved.", 12, Color("#A5B8B8")))
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	actions.add_child(ui_button("▶  FIND A MATCH", Callable(func() -> void: show_page("matchmaking")), true))
	actions.add_child(ui_button("VIEW OPERATIONS  →", Callable(func() -> void: show_page("training")), false))
	copy.add_child(actions)
	var side := make_label("LIVE BUILD 0.9.4\n\nRIFT / FALL", 8, C_MUTED)
	side.position = Vector2(760, 24)
	layer.add_child(side)
	var stats := make_label("ACTIVE OPERATORS  18,642       YOUR STREAK  04 WINS       SEASON RANK  VECTOR IV\n\nSYNCED TO EU NORTH", 8, C_MUTED)
	stats.position = Vector2(28, 242)
	layer.add_child(stats)
	return hero

func build_matchmaking() -> void:
	page_heading("OPERATIONS // MATCHMAKING", "Find your line.", "Choose a ruleset, lock your region, and let the system do the rest.")
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 4)
	for mode in ["RANKED 5V5", "CASUAL", "WINGMAN", "CUSTOM LOBBY"]:
		tabs.add_child(ui_button(mode, Callable(func() -> void: notify(mode + " selected")), mode == "RANKED 5V5"))
	page_host.add_child(tabs)
	var grid := HBoxContainer.new()
	grid.add_theme_constant_override("separation", 16)
	page_host.add_child(grid)
	var search := make_card("SELECTED QUEUE", "RANKED 5V5", 390)
	search[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search[1].add_child(make_label("◉  READY", 12, C_CYAN))
	search[1].add_child(make_label("MAP POOL        RIFT / FALL + 4 MAPS", 9, C_MUTED))
	search[1].add_child(make_label("PARTY SIZE       SOLO / DUO / FULL STACK", 9, C_MUTED))
	search[1].add_child(make_label("SERVER REGION    EU NORTH · 32 ms", 9, C_MUTED))
	var queue_button := ui_button("START SEARCH", Callable(toggle_queue), true)
	queue_button.name = "QueueButton"
	queue_button.add_to_group("queue_button")
	search[1].add_child(queue_button)
	search[1].add_child(make_label("ESTIMATED WAIT  00:43\nBased on 18,642 active operators", 8, C_DIM))
	search[1].add_child(ui_button("↻  PREVIEW POST-MATCH SCREEN", Callable(func() -> void: show_match_summary()), false))
	grid.add_child(search[0])
	var map := make_card("CURRENT MAP // 01", "RIFT / FALL", 390)
	map[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var map_image := TextureRect.new()
	map_image.texture = load("res://assets/ks3-riftfall-hero.jpg")
	map_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	map_image.custom_minimum_size = Vector2(0, 200)
	map_image.modulate = Color(0.45, 0.72, 0.72, 0.72)
	map[1].add_child(map_image)
	map[1].add_child(make_label("PORT HELIX · MEDITERRANEAN EXCLUSION ZONE\nDE_5V5     WEATHER: OVERCAST     BREAKABLES: ACTIVE", 8, C_MUTED))
	grid.add_child(map[0])
	var pool := make_card("MAP POOL // 05", "Know the ground", 170)
	pool[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pool[1].add_child(make_label("RIFT / FALL     VANTA LINE     CINDER YARD     ORBITAL     SALTWORKS", 10, C_CYAN))
	page_host.add_child(pool[0])

func toggle_queue() -> void:
	searching = not searching
	queue_seconds = 0
	if searching:
		queue_timer.start()
		notify("Search party assembled — scanning EU North")
	else:
		queue_timer.stop()
		notify("Matchmaking search cancelled")
	for node in get_tree().get_nodes_in_group("queue_button"):
		node.text = "CANCEL SEARCH" if searching else "START SEARCH"

func _on_queue_tick() -> void:
	queue_seconds += 1
	notify("SEARCHING  %02d:%02d  ·  EU NORTH" % [queue_seconds / 60, queue_seconds % 60])

func show_match_summary() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "RANKED // MATCH COMPLETE — VICTORY"
	dialog.dialog_text = "13 — 09\n\nMVP #01  niko//zero\n27 / 14 / 8     +124 RP\n\nBATTLEPASS XP  +3,840\nITEM DROP      RIFT // AFTERGLOW CASE"
	dialog.add_theme_font_size_override("font_size", 16)
	add_child(dialog)
	dialog.popup_centered(Vector2(520, 360))

func build_inventory() -> void:
	page_heading("ARMORY // COLLECTION", "Inventory.", "Every item tells a story. Yours is still being written.")
	var banner := make_card("EQUIPPED LOADOUT // RANKED", "FEN-9  //  COBALT CIRCUIT", 230)
	banner[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var weapon := TextureRect.new()
	weapon.texture = load("res://assets/fen-9-cobalt.jpg")
	weapon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	weapon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	weapon.custom_minimum_size = Vector2(0, 130)
	weapon.modulate = Color(0.63, 0.85, 0.85, 0.82)
	banner[1].add_child(weapon)
	banner[1].add_child(make_label("ASSAULT RIFLE · MYTHIC · WEAR 0.08          COLLECTION VALUE  ₭84,920", 9, C_CYAN))
	banner[1].add_child(ui_button("INSPECT IN 3D  ⛶", Callable(func() -> void: notify("Inspect mode enabled")), false))
	page_host.add_child(banner[0])
	var filters := HBoxContainer.new()
	filters.add_theme_constant_override("separation", 5)
	for filter in ["ALL ITEMS 24", "WEAPONS 15", "MELEE 03", "GLOVES 02", "STICKERS 04"]:
		filters.add_child(ui_button(filter, Callable(func() -> void: notify(filter + " filter")), filter.begins_with("ALL")))
	page_host.add_child(filters)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 13)
	grid.add_theme_constant_override("v_separation", 13)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_host.add_child(grid)
	var data := [
		["FEN-9", "COBALT CIRCUIT", "MYTHIC", "assets/fen-9-cobalt.jpg", C_CYAN],
		["VANTA EDGE", "NULL", "IMMORTAL", "assets/vanta-edge.jpg", C_PURPLE],
		["KESTREL", "FIELD ISSUE", "RARE", "", C_AMBER],
		["M-7", "SIGNAL BURN", "UNCOMMON", "", C_GREEN],
		["AEGIS", "COLD FORGE", "MYTHIC", "", C_CYAN],
		["ROOK", "CARBON", "COMMON", "", C_MUTED],
	]
	for item in data:
		grid.add_child(item_card(item))

func item_card(item: Array) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 225)
	card.add_theme_stylebox_override("panel", panel_style(Color("#121E25"), item[4]))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	card.add_child(box)
	box.add_child(make_label(item[2] + "                         " + item[0], 8, item[4]))
	if item[3] != "":
		var image := TextureRect.new()
		image.texture = load("res://" + item[3])
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		image.custom_minimum_size = Vector2(0, 135)
		image.modulate = Color(0.65, 0.88, 0.87, 0.8)
		box.add_child(image)
	else:
		box.add_child(make_label("◈\n\nWEAPON PREVIEW", 20, item[4]))
	box.add_child(make_label(item[0] + "\n" + item[1] + "     WEAR 0.08", 9, C_TEXT))
	card.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			notify(item[0] + " equipped to inspection slot")
	)
	return card

func build_case_lab() -> void:
	page_heading("DROP SYSTEM // SEASON 03", "Case lab.", "Open the signal. Chase the improbable.")
	var featured := make_card("FEATURED CASE // RIFT PROTOCOL", "AFTERGLOW COLLECTION", 315)
	featured[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	featured[1].add_child(make_label("A curated drop of hard light, soft metals and objects built for the last round of the night.", 11, Color("#9AAFAF")))
	featured[1].add_child(make_label("18 ITEMS       1 IMMORTAL       02d 14h LEFT", 9, C_AMBER))
	var open := ui_button("OPEN CASE  →", Callable(open_case), true)
	featured[1].add_child(open)
	var art := TextureRect.new()
	art.texture = load("res://assets/fen-9-cobalt.jpg")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.custom_minimum_size = Vector2(0, 130)
	art.modulate = Color(0.58, 0.86, 0.84, 0.8)
	featured[1].add_child(art)
	page_host.add_child(featured[0])
	var grid := HBoxContainer.new()
	grid.add_theme_constant_override("separation", 14)
	for item in [["RIFT // AFTERGLOW", "SEASONAL CASE", C_CYAN, "assets/fen-9-cobalt.jpg"], ["BLACKSITE // 01", "STANDARD CASE", C_PURPLE, "assets/vanta-edge.jpg"], ["SIGNAL // GOLD", "EVENT CASE", C_AMBER, "assets/fen-9-cobalt.jpg"]]:
		var c := make_card(item[1], item[0], 230)
		c[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var image := TextureRect.new()
		image.texture = load("res://" + item[3])
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		image.custom_minimum_size = Vector2(0, 120)
		image.modulate = Color(0.65, 0.85, 0.84, 0.8)
		c[1].add_child(image)
		c[1].add_child(ui_button("OPEN  →", Callable(open_case), false))
		grid.add_child(c[0])
	page_host.add_child(grid)
	var odds := make_card("ODDS // TRANSPARENCY", "Signal distribution", 250)
	odds[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for chance in [["COMMON", "78.00%", C_MUTED], ["UNCOMMON", "16.00%", C_GREEN], ["RARE", "5.00%", C_CYAN], ["MYTHIC", "0.90%", C_PURPLE], ["LEGENDARY", "0.09%", C_AMBER], ["IMMORTAL", "0.01%", C_RED]]:
		odds[1].add_child(make_label("●  " + chance[0] + "                                      " + chance[1], 9, chance[2]))
	page_host.add_child(odds[0])

func open_case() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "RIFT // AFTERGLOW — SIGNAL SCAN"
	dialog.dialog_text = "SCANNING SIGNAL…\n\nTransparent odds · pity protocol active"
	dialog.add_theme_font_size_override("font_size", 16)
	add_child(dialog)
	dialog.popup_centered(Vector2(520, 320))
	get_tree().create_timer(1.5).timeout.connect(func() -> void:
		dialog.dialog_text = "SIGNAL ACQUIRED\n\nVANTA EDGE // NULL\nIMMORTAL · added to inventory"
		notify("Immortal item acquired — added to inventory")
	)

func build_progression() -> void:
	page_heading("COMPETITIVE // SEASON 03", "Read the signal.", "Your rank is a reflection of decisions, not just aim.")
	var hero := make_card("CURRENT SIGNAL", "VECTOR IV", 270)
	hero[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero[1].add_child(make_label("2,480 RATING       +124 THIS WEEK", 15, C_CYAN))
	var progress := ProgressBar.new()
	progress.value = 62
	progress.show_percentage = false
	progress.custom_minimum_size = Vector2(0, 7)
	progress.add_theme_stylebox_override("background", panel_style(Color("#24343A"), Color("#24343A")))
	progress.add_theme_stylebox_override("fill", panel_style(C_CYAN, C_CYAN))
	hero[1].add_child(progress)
	hero[1].add_child(make_label("183 RP TO GO\nOne clean win puts you on the doorstep of Vector V.", 10, C_MUTED))
	hero[1].add_child(ui_button("QUEUE RANKED  →", Callable(func() -> void: show_page("matchmaking")), true))
	page_host.add_child(hero[0])
	var ladder := make_card("RANK LADDER // 06", "The climb", 180)
	ladder[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ladder[1].add_child(make_label("VECTOR I     VECTOR II     VECTOR III     [ VECTOR IV ]     VECTOR V     APEX", 10, C_CYAN))
	ladder[1].add_child(make_label("0—1,199       1,200—1,499       1,500—1,799       1,800—2,099       2,100—2,399       2,400+", 8, C_MUTED))
	page_host.add_child(ladder[0])
	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 16)
	var stats := make_card("PERFORMANCE // 30 DAYS", "Signal quality", 210)
	stats[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats[1].add_child(make_label("RATING TREND\n╱╲___╱╲___╱╲____╱╲___╱", 20, C_CYAN))
	stats[1].add_child(make_label("+18.4% vs last month", 9, C_CYAN))
	bottom.add_child(stats[0])
	var rewards := make_card("SEASON TRACK", "Next unlocks", 210)
	rewards[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rewards[1].add_child(make_label("42   RIFT // AFTERGLOW CASE\n45   1,500 KS3 CREDITS\n50   VANTA EDGE // NULL", 10, C_TEXT))
	bottom.add_child(rewards[0])
	page_host.add_child(bottom)

func build_training() -> void:
	page_heading("SIMULATION // TRAINING DECK", "Sharpen the edge.", "Five minutes here saves five rounds out there.")
	var hero := make_card("ADAPTIVE TRAINING // BETA", "Practice with intent.", 245)
	hero[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero[1].add_child(make_label("The coach tracks habits across aim, timing and comms, then builds the next scenario around the gap.", 11, Color("#9AAFAF")))
	hero[1].add_child(make_label("14 SCENARIOS       03 SKILL AXES       LIVE FEEDBACK", 9, C_CYAN))
	hero[1].add_child(ui_button("START SESSION  →", Callable(func() -> void: notify("Adaptive training session queued")), true))
	page_host.add_child(hero[0])
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 13)
	grid.add_theme_constant_override("v_separation", 13)
	for drill in [["01", "Signal Sense", "AUDIO · DECISIONS", C_CYAN, "68%"], ["02", "Recoil Lab", "AIM · SPRAY", C_AMBER, "42%"], ["03", "Rift Tactics", "MAPS · AI COACH", C_PURPLE, "15%"], ["04", "Team Protocols", "COMMS · UTILITY", C_GREEN, "0%"]]:
		var card := make_card("DRILL // " + drill[2], drill[1], 180)
		card[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card[1].add_child(make_label("MASTERY  " + drill[4], 9, drill[3]))
		card[1].add_child(make_label("Adaptive scenario built from your last 10 rounds.", 10, C_MUTED))
		card[1].add_child(ui_button("▶  START", Callable(func() -> void: notify(drill[1] + " drill loaded")), false))
		grid.add_child(card[0])
	page_host.add_child(grid)

func build_field_hud() -> void:
	page_heading("COMBAT UI // FIELD READ", "Stay in the line.", "A low-noise HUD built for decisions under pressure.")
	var tabs := HBoxContainer.new()
	for mode in ["LIVE HUD", "POST-DEATH ECHO", "SPECTATOR"]:
		tabs.add_child(ui_button(mode, Callable(func() -> void: notify(mode + " preview")), mode == "LIVE HUD"))
	page_host.add_child(tabs)
	var stage := PanelContainer.new()
	stage.custom_minimum_size = Vector2(0, 500)
	stage.add_theme_stylebox_override("panel", panel_style(Color("#0B141B"), Color("#31585C")))
	var layer := Control.new()
	stage.add_child(layer)
	var image := TextureRect.new()
	image.texture = load("res://assets/ks3-riftfall-hero.jpg")
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.modulate = Color(0.32, 0.55, 0.56, 0.8)
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(image)
	var tint := ColorRect.new()
	tint.color = Color(0.02, 0.07, 0.09, 0.43)
	tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(tint)
	var top := make_label("HELIX  04                    ROUND 07 // 01:42                    02  RIFT CELL", 11, C_CYAN)
	top.position = Vector2(25, 20)
	layer.add_child(top)
	var roster := make_label("YOUR FIRETEAM  4 / 5\n\n● niko//zero     100     FEN-9\n● mara.v        85      M-7\n● k0met        100     KESTREL\n● sable_06      42      KESTREL", 9, C_TEXT)
	roster.position = Vector2(25, 85)
	layer.add_child(roster)
	var radar := make_label("╱╲\n ◌  ·   ·\n╲╱\nN", 26, C_CYAN)
	radar.position = Vector2(850, 80)
	layer.add_child(radar)
	var cross := make_label("+\n\nCONTACT · A MAIN   12m", 18, C_TEXT)
	cross.position = Vector2(500, 205)
	layer.add_child(cross)
	var feed := make_label("mara.v + FEN-9  k0met\nRIFT//07 + VEX  sable_06", 8, C_RED)
	feed.position = Vector2(860, 230)
	layer.add_child(feed)
	var bottom := make_label("100 HP    85 ARMOR     [1] [2] [3] [4]                         24 / 90  FEN-9 // COBALT CIRCUIT     ₭ 2,850", 10, C_TEXT)
	bottom.position = Vector2(25, 450)
	layer.add_child(bottom)
	page_host.add_child(stage)
	var rules := HBoxContainer.new()
	rules.add_theme_constant_override("separation", 13)
	for item in [["HUD RULE // 01", "Keep the center clean", "Only actionable contact and objective cues enter the crosshair lane."], ["HUD RULE // 02", "Sound has a shape", "Every important audio event receives a matching subtitle or marker."], ["HUD RULE // 03", "Accessibility first", "Reduce flash, enlarge text, colorblind-safe tags and motion-safe Echo."]]:
		var c := make_card(item[0], item[1], 150)
		c[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c[1].add_child(make_label(item[2], 9, C_MUTED))
		rules.add_child(c[0])
	page_host.add_child(rules)

func build_patch_notes() -> void:
	page_heading("COMMS // BUILD HISTORY", "Patch notes.", "What changed, what matters, what we are watching next.")
	var patch := make_card("0.9.4  //  SEP 18, 2026", "Weather the storm.", 420)
	patch[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	patch[1].add_child(make_label("The first live weather event arrives in Rift Protocol. Readability stays competitive; the world gets louder.", 12, C_TEXT))
	patch[1].add_child(make_label("SYSTEM // WEATHER EVENTS", 9, C_CYAN))
	patch[1].add_child(make_label("Overcast, rain and electrical storms rotate between rounds on Rift / Fall. Weather never changes damage, spawn positions or hitbox visibility.", 10, C_MUTED))
	patch[1].add_child(make_label("MAP // RIFT / FALL", 9, C_CYAN))
	patch[1].add_child(make_label("Added two breakable panels to A Main. Raised B site cover. Adjusted sound zones around Helix pump station.", 10, C_MUTED))
	patch[1].add_child(make_label("WEAPONS // FEN-9", 9, C_CYAN))
	patch[1].add_child(make_label("First-shot recoil recovery reduced by 4%. Stable when disciplined, expensive when panicked.", 10, C_MUTED))
	page_host.add_child(patch[0])

func build_profile() -> void:
	page_heading("OPERATOR // VERIFIED", "niko//zero", "Rift runner · EU North · active since 2024")
	var stats := make_card("CAREER // ALL TIME", "The numbers", 250)
	stats[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats[1].add_child(make_label("486 MATCHES       1.24 K/D       58% WIN RATE       6,840 ELIMINATIONS", 11, C_CYAN))
	stats[1].add_child(make_label("BEST MAP         RIFT / FALL          62% WIN RATE\nFAVOURITE WEAPON FEN-9               1,482 ELIMS", 10, C_MUTED))
	page_host.add_child(stats[0])
	var achievements := make_card("ACHIEVEMENTS // 08 OF 32", "Milestones", 250)
	achievements[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for achievement in ["✓  First light — win your first ranked match", "✓  Hold the line — win 10 rounds without dying", "✓  Thread the needle — land 3 wallbang eliminations", "2/3  Open the signal — acquire an Immortal item"]:
		achievements[1].add_child(make_label(achievement, 10, C_TEXT))
	page_host.add_child(achievements[0])
	page_host.add_child(make_label("RECENT LOADOUT", 9, C_CYAN))
	var items := HBoxContainer.new()
	items.add_theme_constant_override("separation", 13)
	for data in [["FEN-9", "assets/fen-9-cobalt.jpg", C_CYAN], ["VANTA EDGE", "assets/vanta-edge.jpg", C_PURPLE], ["KESTREL", "", C_AMBER], ["AEGIS", "", C_GREEN]]:
		var c := item_card([data[0], "SIGNATURE ITEM", "MYTHIC", data[1], data[2]])
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		items.add_child(c)
	page_host.add_child(items)

func page_heading(kicker: String, title: String, description: String) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 73)
	row.alignment = BoxContainer.ALIGNMENT_END
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_child(make_label(kicker, 8, C_CYAN))
	copy.add_child(make_label(title, 35, C_TEXT))
	copy.add_child(make_label(description, 11, C_MUTED))
	row.add_child(copy)
	row.add_child(make_label("●  EU NORTH   32 ms", 8, C_CYAN))
	page_host.add_child(row)

func make_card(kicker: String, title: String, min_height: float = 0.0) -> Array:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", panel_style(C_PANEL, C_LINE))
	if min_height > 0:
		p.custom_minimum_size = Vector2(0, min_height)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 20)
	p.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 11)
	margin.add_child(box)
	if kicker != "":
		box.add_child(make_label(kicker, 8, C_DIM))
	if title != "":
		box.add_child(make_label(title, 18, C_TEXT))
	return [p, box]

func add_operation(box: VBoxContainer, index: String, title: String, description: String, reward: String, color: Color, progress_text: String) -> void:
	var line := HBoxContainer.new()
	line.custom_minimum_size = Vector2(0, 62)
	line.add_theme_constant_override("separation", 10)
	line.add_child(make_label(index, 12, color))
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_child(make_label(title, 10, C_TEXT))
	copy.add_child(make_label(description, 8, C_MUTED))
	copy.add_child(make_label(progress_text + "                         " + reward, 7, color))
	line.add_child(copy)
	box.add_child(line)

func add_squad_row(box: VBoxContainer, name: String, role: String, status: String) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 43)
	row.add_child(make_label("●", 12, C_CYAN if status != "AWAY" else C_DIM))
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_child(make_label(name, 10, C_TEXT))
	copy.add_child(make_label(role, 7, C_DIM))
	row.add_child(copy)
	row.add_child(make_label(status, 7, C_AMBER if status == "IN MATCH" else C_MUTED))
	box.add_child(row)

func section_rule(text: String) -> Label:
	var line := make_label(text, 8, C_DIM)
	line.custom_minimum_size = Vector2(0, 22)
	return line

func make_label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	# Keep labels intrinsic-width by default. Autowrap in every label made HBox/VBox
	# children collapse to a few pixels, rendering the UI as one letter per line.
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	return label

func ui_button(text: String, callback: Callable, accent: bool) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 36)
	b.add_theme_font_size_override("font_size", 9)
	b.add_theme_color_override("font_color", C_DEEP if accent else C_MUTED)
	b.add_theme_color_override("font_hover_color", C_DEEP if accent else C_CYAN)
	b.add_theme_stylebox_override("normal", panel_style(C_CYAN if accent else Color("#101B21"), C_CYAN if accent else C_LINE))
	b.add_theme_stylebox_override("hover", panel_style(Color("#9AF0EA") if accent else Color("#152A30"), C_CYAN))
	b.add_theme_stylebox_override("pressed", panel_style(Color("#4BAAA6") if accent else Color("#0E171C"), C_CYAN))
	if callback.is_valid():
		b.pressed.connect(callback)
	return b

func panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.corner_radius_top_left = 1
	style.corner_radius_top_right = 1
	style.corner_radius_bottom_left = 1
	style.corner_radius_bottom_right = 1
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func notify(message: String) -> void:
	toast.text = message
	toast.visible = true
	toast_timer.start()

func open_settings() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "SYSTEM // CONFIGURATION"
	dialog.dialog_text = "VIDEO\nFullscreen · 2560 × 1440 · Tactical color profile\n\nAUDIO\nMaster 82% · Voice 100% · Music 42%\n\nCONTROLS\nRaw input · Sensitivity 1.4 · FOV 103\n\nCROSSHAIR\nTeal signal · Dynamic gap off\n\nChanges apply instantly."
	dialog.add_theme_font_size_override("font_size", 14)
	add_child(dialog)
	dialog.popup_centered(Vector2(560, 460))

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()
