class_name World extends Node

const PLAYER_SCENE = preload("res://scenes/player.tscn")

@export var enemy1: CharacterBody3D
@export var enemy2: CharacterBody3D
@export var enemy3: CharacterBody3D
@export var multiplayer_spawner : MultiplayerSpawner

@onready var players_spawn_node := %Players
@onready var zone_items := %ZoneItems

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	multiplayer_spawner.spawn_function = custom_spawn
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(delete_player)

func _on_enemy_spawn_timer_timeout() -> void:
	if !enemy1.visible:
		enemy1.show()
	if !enemy2.visible:
		enemy2.show()
	if !enemy3.visible:
		enemy3.show()

#------old
# func add_player(id: int):
# 	print("SERVER: add_player function called")
# 	var player := PLAYER_SCENE.instantiate()
# 	player.peer_id = id
# 	player.name = str(id)
# 	player.set_multiplayer_authority(id)
# 	players_spawn_node.add_child(player, true)
# 	print("SERVER: player ", player.name, " with authority ", player.get_multiplayer_authority())

func add_player(id: int) -> void:
	if not multiplayer.is_server(): return
	
	var spawn_position = Vector3.ZERO
	multiplayer_spawner.spawn([id, spawn_position])
	print("Player %d spawned at " % [id] + str(spawn_position))

#------old
# func delete_player(id: int):
# 	print("SERVER: delete_player function called")
# 	if not has_node(str(id)):
# 		return
# 	get_node(str(id)).queue_free()

func delete_player(id: int) -> void:
	if not multiplayer.is_server(): return
	print("SERVER: delete_player function called")
	players_spawn_node.get_node(str(id)).queue_free()

func custom_spawn(vars) -> Node:
	var id = vars[0]
	var pos = vars[1]

	var player: Player = PLAYER_SCENE.instantiate()
	player.set_multiplayer_authority(id)
	player.name = str(id)
	player.peer_id = id
	player.position = pos
	return player


func _on_connect_client_pressed() -> void:
	pass # Replace with function body.
