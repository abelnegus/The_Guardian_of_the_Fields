extends Node2D

var detectRadius: int = 200
var cooldownTime: int = 15
var zebuCalfActive: bool = true

func _ready():
	# Example: start monitoring hazards
	CalculateRadius()

func CalculateRadius():
	# Find hazards within radius
	var hazards = get_tree().get_nodes_in_group("Hazards")
	for hazard in hazards:
		if position.distance_to(hazard.position) <= detectRadius:
			$TheGuardian.CommandStunAttack(hazard)

func ManageCooldown():
	print("Cooldown started for %s seconds" % cooldownTime)
	await get_tree().create_timer(cooldownTime).timeout
	print("Cooldown finished, ready again")

func log_result(success: bool):
	if success:
		print("Stun Applied and logged")
	else:
		print("Stun missed, not logged")
