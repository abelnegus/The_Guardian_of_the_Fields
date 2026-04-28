extends Node2D

@onready var path_node = $Path2D
@onready var path_follow = $Path2D/PathFollow2D

func create_swoop_path(target_pos: Vector2):
	var curve = Curve2D.new()
	var start_pos = global_position
	
	# Calculate a point past the target to complete the "U"
	var end_pos = Vector2(target_pos.x + (target_pos.x - start_pos.x), start_pos.y)
	
	# Add points to the curve
	curve.add_point(to_local(start_pos))
	curve.add_point(to_local(target_pos)) # The "Dip"
	curve.add_point(to_local(end_pos))   # The "Pull Up"
	
	path_node.curve = curve
	start_swoop()

func start_swoop():
	var tween = create_tween()
	# Animates the progress along the path from start (0) to finish (1)
	tween.tween_property(path_follow, "progress_ratio", 1.0, 1.5).set_trans(Tween.TRANS_SINE)
	await tween.finished
	# Reset for next attack
	path_follow.progress_ratio = 0
