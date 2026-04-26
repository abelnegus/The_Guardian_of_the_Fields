extends Node2D

func _ready():
	print("========================================")
	print("FRIENDLY FIRE TEST")
	print("========================================")
	
	# Load friendly fire system
	var friendly_fire = preload("res://tasks/S-15_kaleabe/friendly_fire.gd").new()
	add_child(friendly_fire)
	
	await get_tree().create_timer(1.0).timeout
	
	# Run test
	friendly_fire._test_friendly_fire()
