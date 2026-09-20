class_name KS3NetworkManager
extends Node
## Minimal Godot 4.5+ ENet lifecycle stub.
## Gameplay-critical validation belongs on the dedicated server, not in this client UI.

signal connected_to_server
signal connection_failed(reason: String)
signal peer_joined(peer_id: int)
signal peer_left(peer_id: int)

const DEFAULT_PORT := 7777
const MAX_PLAYERS := 10

var peer: ENetMultiplayerPeer

func host(port: int = DEFAULT_PORT, max_players: int = MAX_PLAYERS) -> Error:
	peer = ENetMultiplayerPeer.new()
	var result := peer.create_server(port, max_players)
	if result != OK:
		connection_failed.emit("Unable to bind ENet server: %s" % result)
		return result
	multiplayer.multiplayer_peer = peer
	if not multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.connect(_on_peer_connected)
	if not multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	return OK

func join(address: String, port: int = DEFAULT_PORT) -> Error:
	peer = ENetMultiplayerPeer.new()
	var result := peer.create_client(address, port)
	if result != OK:
		connection_failed.emit("Unable to create ENet client: %s" % result)
		return result
	multiplayer.multiplayer_peer = peer
	if not multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		multiplayer.connected_to_server.connect(_on_connected_to_server)
	if not multiplayer.connection_failed.is_connected(_on_connection_failed):
		multiplayer.connection_failed.connect(_on_connection_failed)
	return OK

func shutdown() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	peer = null

func _on_connected_to_server() -> void:
	connected_to_server.emit()

func _on_connection_failed() -> void:
	connection_failed.emit("ENet handshake failed")

func _on_peer_connected(peer_id: int) -> void:
	peer_joined.emit(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	peer_left.emit(peer_id)
