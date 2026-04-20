extends Node

var inRadius: bool = false

func CommandStunAttack(hazard):
	# Delegate to ZebuCalf
	$ZebuCalf.DetectHazard(hazard)
