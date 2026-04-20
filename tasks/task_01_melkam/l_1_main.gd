extends Node2D

func _ready():
	# 1. Instance the Guardian (Player)
	var player_scene = load("res://Scenes/Player/Guardian.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	
	# 2. Use your PlayerSpawn marker to set position
	player.global_position = $PlayerSpawn.global_position
	
	# 3. Make the Camera follow the player
	# We move the camera from the level root to be a child of the player
	remove_child($Camera2D)
	player.add_child($Camera2D)
	
	# 4. DEP #14: Ensure player works during time-slow events
	player.process_mode = Node.PROCESS_MODE_ALWAYS
