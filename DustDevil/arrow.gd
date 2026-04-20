extends CharacterBody2D

func _ready():
	velocity = Vector2(400, 0)

func _physics_process(delta):
	move_and_slide()
