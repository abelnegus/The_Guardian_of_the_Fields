extends Path2D

# Nodes
@onready var path_follow = $PathFollow2D
@onready var sprite = $PathFollow2D/AnimatedSprite2D
@onready var detection_area = $PathFollow2D/Area2D

# Movement Settings
var speed := 60.0
var current_speed := 60.0
var is_blocked := false

# Animation Settings (Simulated Leg Movement)
var walk_tempo := 8.0
var step_height := 3.0
var time := 0.0

func _ready():
	# Instruction: Register as an objective
	add_to_group("objective")
	
	# Instruction: Connect signals for Jackal detection
	detection_area.area_entered.connect(_on_jackal_entered)
	detection_area.area_exited.connect(_on_jackal_exited)

func _process(delta):
	# Handle Stopping/Starting logic
	if is_blocked:
		current_speed = 0.0
	else:
		current_speed = speed
		# Only animate the "walking legs" if the camels are actually moving
		_animate_walking(delta)
	
	# Movement along the PathFollow2D
	path_follow.progress += current_speed * delta
	
	# Instruction: Safe arrival logic
	if path_follow.progress_ratio >= 1.0:
		_on_safe_arrival()

func _animate_walking(delta):
	time += delta * walk_tempo
	# This creates a "stomp" effect that looks like legs hitting the ground
	sprite.position.y = -abs(sin(time) * step_height)
	# This creates a "shoulder sway"
	sprite.rotation = sin(time) * 0.04

func _on_jackal_entered(area):
	# Instruction: If S-25 Jackal overlaps, set speed = 0
	if area.is_in_group("hazard"):
		is_blocked = true

func _on_jackal_exited(area):
	# Instruction: Resume when Jackal leaves
	if area.is_in_group("hazard"):
		is_blocked = false

func _on_safe_arrival():
	# Instruction: Global.score += 20
	Global.score += 20
	print("S-22 Objective Complete. Score: ", Global.score)
	queue_free()
