extends RefCounted
## Shared weapon catalogue for the menu and the local 3D match.
## The catalogue intentionally stays data-driven so future multiplayer loadouts
## can reuse the same names, categories and balance fields.

const WEAPONS: Array[Dictionary] = [
	{
		"id": "fen9",
		"name": "FEN-9 COBALT",
		"category": "ШТУРМОВАЯ ВИНТОВКА",
		"damage": 34,
		"magazine": 30,
		"reserve": 90,
		"cooldown": 0.16,
		"is_knife": false,
		"color": Color("#73DDD7")
	},
	{
		"id": "vanta_ar",
		"name": "VANTA AR-4",
		"category": "ШТУРМОВАЯ ВИНТОВКА",
		"damage": 38,
		"magazine": 25,
		"reserve": 75,
		"cooldown": 0.19,
		"is_knife": false,
		"color": Color("#9B91E8")
	},
	{
		"id": "kestrel",
		"name": "KESTREL-5",
		"category": "ШТУРМОВАЯ ВИНТОВКА",
		"damage": 31,
		"magazine": 35,
		"reserve": 105,
		"cooldown": 0.13,
		"is_knife": false,
		"color": Color("#D8B173")
	},
	{
		"id": "aegis",
		"name": "AEGIS M4",
		"category": "ШТУРМОВАЯ ВИНТОВКА",
		"damage": 36,
		"magazine": 30,
		"reserve": 90,
		"cooldown": 0.15,
		"is_knife": false,
		"color": Color("#72C58D")
	},
	{
		"id": "rook",
		"name": "ROOK-7",
		"category": "ШТУРМОВАЯ ВИНТОВКА",
		"damage": 42,
		"magazine": 20,
		"reserve": 60,
		"cooldown": 0.22,
		"is_knife": false,
		"color": Color("#C77C6F")
	},
	{
		"id": "lancer",
		"name": "LANCER-11",
		"category": "ШТУРМОВАЯ ВИНТОВКА",
		"damage": 29,
		"magazine": 40,
		"reserve": 120,
		"cooldown": 0.11,
		"is_knife": false,
		"color": Color("#B0C4C8")
	},
	{
		"id": "rift_smg",
		"name": "RIFT-9",
		"category": "ПИСТОЛЕТ-ПУЛЕМЁТ",
		"damage": 24,
		"magazine": 32,
		"reserve": 128,
		"cooldown": 0.08,
		"is_knife": false,
		"color": Color("#56B6B6")
	},
	{
		"id": "cinder",
		"name": "CINDER SMG",
		"category": "ПИСТОЛЕТ-ПУЛЕМЁТ",
		"damage": 28,
		"magazine": 28,
		"reserve": 112,
		"cooldown": 0.10,
		"is_knife": false,
		"color": Color("#E08A61")
	},
	{
		"id": "velum",
		"name": "VELUM-2",
		"category": "ПИСТОЛЕТ-ПУЛЕМЁТ",
		"damage": 21,
		"magazine": 36,
		"reserve": 144,
		"cooldown": 0.07,
		"is_knife": false,
		"color": Color("#8F9BE0")
	},
	{
		"id": "marauder",
		"name": "MARAUDER-12",
		"category": "ДРОБОВИК",
		"damage": 78,
		"magazine": 8,
		"reserve": 32,
		"cooldown": 0.70,
		"is_knife": false,
		"color": Color("#D99E62")
	},
	{
		"id": "breach",
		"name": "BREACHER",
		"category": "ДРОБОВИК",
		"damage": 91,
		"magazine": 6,
		"reserve": 24,
		"cooldown": 0.85,
		"is_knife": false,
		"color": Color("#B86D59")
	},
	{
		"id": "hammer",
		"name": "HAMMER-4",
		"category": "ДРОБОВИК",
		"damage": 68,
		"magazine": 10,
		"reserve": 40,
		"cooldown": 0.56,
		"is_knife": false,
		"color": Color("#A7C7B2")
	},
	{
		"id": "talon_dmr",
		"name": "TALON DMR",
		"category": "МАРКСМАНСКАЯ",
		"damage": 72,
		"magazine": 12,
		"reserve": 48,
		"cooldown": 0.42,
		"is_knife": false,
		"color": Color("#C7A878")
	},
	{
		"id": "pylon",
		"name": "PYLON-8",
		"category": "МАРКСМАНСКАЯ",
		"damage": 64,
		"magazine": 16,
		"reserve": 64,
		"cooldown": 0.34,
		"is_knife": false,
		"color": Color("#83B8C7")
	},
	{
		"id": "meridian",
		"name": "MERIDIAN SR",
		"category": "СНАЙПЕРСКАЯ",
		"damage": 100,
		"magazine": 5,
		"reserve": 25,
		"cooldown": 1.05,
		"is_knife": false,
		"color": Color("#D8D5C1")
	},
	{
		"id": "kite",
		"name": "KITE-9",
		"category": "ПИСТОЛЕТ",
		"damage": 42,
		"magazine": 15,
		"reserve": 60,
		"cooldown": 0.24,
		"is_knife": false,
		"color": Color("#9FDFD6")
	},
	{
		"id": "sable",
		"name": "SABLE P1",
		"category": "ПИСТОЛЕТ",
		"damage": 48,
		"magazine": 12,
		"reserve": 48,
		"cooldown": 0.30,
		"is_knife": false,
		"color": Color("#D7A8B4")
	},
	{
		"id": "echo",
		"name": "ECHO BURST",
		"category": "ПИСТОЛЕТ",
		"damage": 32,
		"magazine": 20,
		"reserve": 80,
		"cooldown": 0.12,
		"is_knife": false,
		"color": Color("#B0A9E7")
	},
	{
		"id": "arc",
		"name": "ARC SIDEARM",
		"category": "ПИСТОЛЕТ",
		"damage": 55,
		"magazine": 8,
		"reserve": 32,
		"cooldown": 0.36,
		"is_knife": false,
		"color": Color("#E4C177")
	},
	{
		"id": "palm",
		"name": "PALM-7",
		"category": "ПИСТОЛЕТ",
		"damage": 37,
		"magazine": 18,
		"reserve": 72,
		"cooldown": 0.18,
		"is_knife": false,
		"color": Color("#78A9A6")
	},
	{
		"id": "vanta_edge",
		"name": "VANTA EDGE",
		"category": "НОЖ",
		"damage": 100,
		"magazine": 1,
		"reserve": 0,
		"cooldown": 0.46,
		"is_knife": true,
		"color": Color("#9B91E8")
	},
	{
		"id": "sandglass",
		"name": "SANDGLASS",
		"category": "НОЖ",
		"damage": 100,
		"magazine": 1,
		"reserve": 0,
		"cooldown": 0.50,
		"is_knife": true,
		"color": Color("#E0B36E")
	},
	{
		"id": "dune_fang",
		"name": "DUNE FANG",
		"category": "НОЖ",
		"damage": 100,
		"magazine": 1,
		"reserve": 0,
		"cooldown": 0.43,
		"is_knife": true,
		"color": Color("#D98563")
	},
	{
		"id": "cobalt_karambit",
		"name": "COBALT KARAMBIT",
		"category": "НОЖ",
		"damage": 100,
		"magazine": 1,
		"reserve": 0,
		"cooldown": 0.39,
		"is_knife": true,
		"color": Color("#72DDD7")
	},
	{
		"id": "rift_tanto",
		"name": "RIFT TANTO",
		"category": "НОЖ",
		"damage": 100,
		"magazine": 1,
		"reserve": 0,
		"cooldown": 0.45,
		"is_knife": true,
		"color": Color("#B6C3C7")
	},
	{
		"id": "helix_kukri",
		"name": "HELIX KUKRI",
		"category": "НОЖ",
		"damage": 100,
		"magazine": 1,
		"reserve": 0,
		"cooldown": 0.56,
		"is_knife": true,
		"color": Color("#A6D09F")
	},
	{
		"id": "scoria_talon",
		"name": "SCORIA TALON",
		"category": "НОЖ",
		"damage": 100,
		"magazine": 1,
		"reserve": 0,
		"cooldown": 0.48,
		"is_knife": true,
		"color": Color("#E57968")
	},
	{
		"id": "nomad_machete",
		"name": "NOMAD MACHETE",
		"category": "НОЖ",
		"damage": 100,
		"magazine": 1,
		"reserve": 0,
		"cooldown": 0.62,
		"is_knife": true,
		"color": Color("#C5A77D")
	},
	{
		"id": "glass_shard",
		"name": "GLASS SHARD",
		"category": "НОЖ",
		"damage": 100,
		"magazine": 1,
		"reserve": 0,
		"cooldown": 0.35,
		"is_knife": true,
		"color": Color("#8DD9D4")
	},
	{
		"id": "ember_stiletto",
		"name": "EMBER STILETTO",
		"category": "НОЖ",
		"damage": 100,
		"magazine": 1,
		"reserve": 0,
		"cooldown": 0.41,
		"is_knife": true,
		"color": Color("#F0A36B")
	},
]


static func firearms() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for weapon in WEAPONS:
		if not bool(weapon["is_knife"]):
			result.append(weapon)
	return result


static func knives() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for weapon in WEAPONS:
		if bool(weapon["is_knife"]):
			result.append(weapon)
	return result
