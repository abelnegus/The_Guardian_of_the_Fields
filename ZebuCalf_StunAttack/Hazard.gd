extends CharacterBody2D   # or KinematicBody2D in Godot 3

var hazard_id: int
var isStunned: bool = false

func TakeDamage(amount: float):
	print("Hazard %s took %s damage" % [hazard_id, amount])

func ApplyStun(duration: int):
	isStunned = true
	print("Hazard stunned for %s seconds" % duration)
	await get_tree().create_timer(duration).timeout
	isStunned = false
	print("Hazard recovered")
