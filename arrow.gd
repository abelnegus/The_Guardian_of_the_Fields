extends CharacterBody2D

# Moving right at 400 pixels per second
var velocity_vector = Vector2(400, 0) 

func _physics_process(delta):
	# Simple movement for testing the deflection
	var _collision = move_and_collide(velocity_vector * delta)
