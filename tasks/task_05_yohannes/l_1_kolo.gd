extends Area2D # Keep this to match your root node "EagleEye"

@onready var buff_timer = $BuffTimer
# We reference the child Area2D that is already in your scene tree
@onready var detection_area = $Area2D 

var player_ref: CharacterBody2D = null

func _ready():
	# FIX: Connect the signal FROM the child Area2D, not 'self'
	detection_area.body_entered.connect(_on_body_entered)
	buff_timer.timeout.connect(_on_buff_timer_timeout)

func _on_body_entered(body):
	# Verify if the object is The Guardian
	if body.is_in_group("player") or body.name == "TheGuardian":
		player_ref = body
		activate_eagle_eye()

func activate_eagle_eye():
	Engine.time_scale = 0.5
	
	if player_ref:
		player_ref.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Audio Pitch Fix (The loop your manager wanted)
	for node in get_tree().get_nodes_in_group("audio"):
		node.pitch_scale = 0.5
	
	buff_timer.start(8.0)
	
	# Visual Feedback - access the sprite inside the child area
	$Area2D/Sprite2D.hide()
	detection_area.set_deferred("monitoring", false)

func _on_buff_timer_timeout():
	Engine.time_scale = 1.0
	
	for node in get_tree().get_nodes_in_group("audio"):
		node.pitch_scale = 1.0
		
	if player_ref:
		player_ref.process_mode = Node.PROCESS_MODE_INHERIT
	
	queue_free()
