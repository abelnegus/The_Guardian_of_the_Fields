extends Node2D  # Fix #1: No longer extending shared file

@onready var path_follow = $Path2D/PathFollow2D
@onready var detection_area = $Path2D/PathFollow2D/Area2D

var speed := 60.0
var is_blocked := false

func _ready():
	add_to_group("objective")
	# Ensure the detection area is looking for hazards
	if detection_area:
		detection_area.collision_layer = 2
		detection_area.collision_mask = 4
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)

func _process(delta):
	if not is_blocked:
		path_follow.progress += speed * delta
		
		# Fix #9 (Previous): Check goal only when moving
		if path_follow.progress_ratio >= 1.0:
			_on_reached_goal()

func _on_body_entered(body):
	# Fix #4: Removed "player" check. Only hazards block.
	if body.is_in_group("hazard"):
		is_blocked = true

func _on_body_exited(body):
	if body.is_in_group("hazard"):
		var bodies = detection_area.get_overlapping_bodies()
		var still_blocked = false
		for b in bodies:
			if b.is_in_group("hazard"):
				still_blocked = true
				break
		is_blocked = still_blocked

func _on_reached_goal():
	# Fix #2 & #3: Direct access to Global.score
	Global.score += 20
	queue_free()
