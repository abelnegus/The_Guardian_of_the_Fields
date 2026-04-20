extends CharacterBody2D

@export var speed: float = 100.0
@export var lifetime: float = 20.0
@export var deviation_angle: float = 15.0 

var direction: Vector2
var timer: float = 0.0

func _ready():
	# Randomized movement direction
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	# Essential for the team's damage system
	add_to_group("hazard")

func _physics_process(delta):
	# Movement logic
	velocity = direction * speed
	move_and_slide()
	
	# Timer logic
	timer += delta
	if timer >= lifetime:
		queue_free()

# MUST BE CONNECTED TO Area2D 'body_entered' signal
func _on_area_2d_body_entered(body):
	print("Collision detected!")
	if body.is_in_group("arrow"):
		print("Arrow trajectory shifted!")
		var angle = deg_to_rad(randf_range(-deviation_angle, deviation_angle))
		body.velocity = body.velocity.rotated(angle)
