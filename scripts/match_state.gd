class_name KS3MatchState
extends Node
## Server-authoritative round state skeleton for the first gameplay slice.
## Clients request actions; only the server mutates score, Key and economy.

signal phase_changed(phase: StringName)
signal score_changed(attackers: int, defenders: int)
signal key_state_changed(state: StringName)

const ROUND_TIME_SECONDS := 115.0
const PLANT_TIME_SECONDS := 4.0
const DEFUSE_TIME_SECONDS := 5.0

var phase: StringName = &"buy"
var round_number := 1
var attackers_score := 0
var defenders_score := 0
var round_clock := ROUND_TIME_SECONDS
var key_state: StringName = &"attacker_spawn"
var key_holder_peer := 0

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	if phase == &"live" or phase == &"planted":
		round_clock = maxf(round_clock - delta, 0.0)
		if round_clock <= 0.0 and phase == &"live":
			finish_round(&"time")

@rpc("any_peer", "call_remote", "reliable")
func request_start_round() -> void:
	if not multiplayer.is_server() or phase != &"buy":
		return
	phase = &"live"
	round_clock = ROUND_TIME_SECONDS
	phase_changed.emit(phase)

@rpc("any_peer", "call_remote", "reliable")
func request_pick_up_key() -> void:
	if not multiplayer.is_server() or phase != &"live":
		return
	key_holder_peer = multiplayer.get_remote_sender_id()
	key_state = &"carried"
	key_state_changed.emit(key_state)

@rpc("any_peer", "call_remote", "reliable")
func request_plant(site_id: StringName) -> void:
	if not multiplayer.is_server() or phase != &"live":
		return
	if key_state != &"carried" or site_id not in [&"a", &"b"]:
		return
	key_state = StringName("planted_" + String(site_id))
	phase = &"planted"
	key_state_changed.emit(key_state)
	phase_changed.emit(phase)

@rpc("any_peer", "call_remote", "reliable")
func request_defuse() -> void:
	if not multiplayer.is_server() or phase != &"planted":
		return
	finish_round(&"defuse")

func finish_round(reason: StringName) -> void:
	if not multiplayer.is_server():
		return
	if reason == &"defuse" or reason == &"time":
		defenders_score += 1
	else:
		attackers_score += 1
	score_changed.emit(attackers_score, defenders_score)
	phase = &"debrief"
	phase_changed.emit(phase)
	key_holder_peer = 0
	key_state = &"attacker_spawn"
	key_state_changed.emit(key_state)

func reset_for_next_round() -> void:
	if not multiplayer.is_server():
		return
	round_number += 1
	round_clock = ROUND_TIME_SECONDS
	phase = &"buy"
	phase_changed.emit(phase)
