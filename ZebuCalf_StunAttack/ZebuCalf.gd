extends Node2D

var detectionRadius: float = 250.0
var isCoolingDown: bool = false

func DetectHazard(hazard):
	if position.distance_to(hazard.position) <= detectionRadius:
		var trajectory = calculateTrajectory(hazard)
		performsStunImpact(hazard, trajectory)

func calculateTrajectory(hazard):
	# Simple vector toward hazard
	return (hazard.position - position).normalized()

func performsStunImpact(hazard, trajectory):
	# Simulate charge success/failure
	var success = randf() > 0.2   # 80% chance success
	if success:
		hazard.ApplyStun(3)
		get_parent().log_result(true)
	else:
		print("Intercept failed")
		get_parent().log_result(false)
	isCoolingDown = true
	get_parent().ManageCooldown()
	isCoolingDown = false
