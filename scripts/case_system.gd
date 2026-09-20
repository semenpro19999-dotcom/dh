class_name CaseSystem
extends RefCounted
## Local prototype case economy.
## The match client only presents the result; production must move the roll to the server.

const Arsenal = preload("res://scripts/arsenal.gd")

const RARITY_ODDS: Array[Dictionary] = [
	{"id": "common", "label": "COMMON", "chance": 78.0, "color": Color("#B9A99A")},
	{"id": "uncommon", "label": "UNCOMMON", "chance": 16.0, "color": Color("#74D39B")},
	{"id": "rare", "label": "RARE", "chance": 5.0, "color": Color("#69B7FF")},
	{"id": "mythic", "label": "MYTHIC", "chance": 0.9, "color": Color("#C28AFF")},
	{"id": "legendary", "label": "LEGENDARY", "chance": 0.09, "color": Color("#FFB65F")},
	{"id": "immortal", "label": "IMMORTAL", "chance": 0.01, "color": Color("#FF6F86")}
]

const ITEMS_BY_RARITY := {
	"common": ["rift_smg", "cinder", "velum", "kite", "palm", "glass_shard"],
	"uncommon": ["fen9", "vanta_ar", "kestrel", "sable", "dune_fang", "rift_tanto"],
	"rare": ["aegis", "rook", "marauder", "breach", "cobalt_karambit", "helix_kukri"],
	"mythic": ["lancer", "talon_dmr", "pylon", "arc", "scoria_talon"],
	"legendary": ["awm", "nomad_machete", "ember_stiletto"],
	"immortal": ["vanta_edge", "sandglass", "echo"]
}

const SAVE_PATH := "user://ks3_cases.cfg"

var tokens := 3
var pity_without_mythic := 0
var opened_count := 0
var inventory: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()


func _init() -> void:
	rng.randomize()
	load_state()


func load_state() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	tokens = int(config.get_value("case", "tokens", tokens))
	pity_without_mythic = int(config.get_value("case", "pity", pity_without_mythic))
	opened_count = int(config.get_value("case", "opened_count", opened_count))
	var saved_inventory = config.get_value("case", "inventory", [])
	if saved_inventory is Array:
		inventory.clear()
		for saved_item in saved_inventory:
			if saved_item is Dictionary:
				inventory.append(saved_item)


func save_state() -> void:
	var config := ConfigFile.new()
	config.set_value("case", "tokens", tokens)
	config.set_value("case", "pity", pity_without_mythic)
	config.set_value("case", "opened_count", opened_count)
	config.set_value("case", "inventory", inventory)
	config.save(SAVE_PATH)


func open_standard_case() -> Dictionary:
	if tokens <= 0:
		return {"ok": false, "message": "НЕТ ТОКЕНОВ", "tokens": tokens}
	tokens -= 1
	opened_count += 1
	var rarity := roll_rarity()
	var pity_triggered := pity_without_mythic >= 10
	if pity_triggered:
		rarity = roll_pity_rarity()
	if is_mythic_or_higher(rarity):
		pity_without_mythic = 0
	else:
		pity_without_mythic += 1
	var item_id := pick_item_id(rarity)
	var item_name := weapon_name(item_id)
	var duplicate := inventory_has_item(item_id)
	var result := {
		"ok": true,
		"case_open_id": "local-%04d" % opened_count,
		"rarity": rarity,
		"item_id": item_id,
		"item_name": item_name,
		"duplicate": duplicate,
		"pity_triggered": pity_triggered,
		"tokens": tokens,
		"pity": pity_without_mythic
	}
	inventory.append(result)
	save_state()
	return result


func roll_rarity() -> String:
	var roll := rng.randf() * 100.0
	var cursor := 0.0
	for row in RARITY_ODDS:
		cursor += float(row["chance"])
		if roll < cursor:
			return str(row["id"])
	return "common"


func roll_pity_rarity() -> String:
	var roll := rng.randf()
	if roll < 0.70:
		return "mythic"
	if roll < 0.95:
		return "legendary"
	return "immortal"


func pick_item_id(rarity: String) -> String:
	var pool: Array = ITEMS_BY_RARITY.get(rarity, ITEMS_BY_RARITY["common"])
	if pool.is_empty():
		return "fen9"
	return str(pool[rng.randi_range(0, pool.size() - 1)])


func inventory_has_item(item_id: String) -> bool:
	for item in inventory:
		if str(item.get("item_id", "")) == item_id:
			return true
	return false


func weapon_name(item_id: String) -> String:
	for weapon in Arsenal.WEAPONS:
		if str(weapon["id"]) == item_id:
			return str(weapon["name"])
	return item_id


func is_mythic_or_higher(rarity: String) -> bool:
	return rarity in ["mythic", "legendary", "immortal"]


func odds_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for row in RARITY_ODDS:
		rows.append(row.duplicate(true))
	return rows


func inventory_copy() -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	for item in inventory:
		items.append(item.duplicate(true))
	return items


func pity_percent() -> int:
	return mini(100, int(float(pity_without_mythic) / 10.0 * 100.0))
