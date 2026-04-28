extends Node2D

@onready var timer = $Timer
@onready var Audio = $AudioStreamPlayer2D
# Reference your Path2D nodes
@onready var vultures = [$Vulture_1, $Vulture_2, $Vulture_3,$Vulture_4]

func _on_timer_timeout():
	# Pick a random vulture to attack
	var victim = vultures.pick_random()
	Audio.play()
	
	# Capture the target position ONCE (e.g., the Icon's current position)
	var target_pos = $Icon.global_position
	
	# Tell the PathFollow2D inside that Path2D to swoop
	# Path -> PathFollow2D
	var controller = victim.get_node("PathFollow2D")
	if controller:
		controller.start_swoop(target_pos)
