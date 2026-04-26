extends "res://Scripts/Core/Entity.gd"

signal lion_pounce_warning
signal lion_pounced

const STEALTH_OPACITY = 0.3
const POUNCE_DISTANCE = 120
const WARNING_TIME = 1.5
const PATROL_SPEED = 50
const PATROL_LEFT = 300
const PATROL_RIGHT = 700
const POUNCE_COOLDOWN = 3.0

var is_hidden = false
var is_pouncing = false
var on_cooldown = false
var target_zebu = null
var target_player = null
var patrol_direction = 1

@onready var sprite = $AnimatedSprite2D

# Load animation resources
@onready var walk_frames = preload("res://tasks/task_13_lion_stealth/L2_Lion_Walk.tres")
@onready var pounce_frames = preload("res://tasks/task_13_lion_stealth/L2_Lion_Pounce.tres")

func _ready():
	print("LION: Script ready")
	add_to_group("lion")
	modulate.a = 1.0
	
	# Start with walk animation
	if walk_frames:
		sprite.sprite_frames = walk_frames
		sprite.play("walk")
		print("LION: Walk animation loaded")
	else:
		print("LION: ERROR - Walk animation not found!")

func _physics_process(delta):
	# Patrol movement
	if not is_pouncing:
		position.x += PATROL_SPEED * patrol_direction * delta
		
		if position.x >= PATROL_RIGHT:
			patrol_direction = -1
			if sprite:
				sprite.flip_h = true
		elif position.x <= PATROL_LEFT:
			patrol_direction = 1
			if sprite:
				sprite.flip_h = false
	
	# Check pounce on ZEBU
	if target_zebu and is_hidden and not is_pouncing and not on_cooldown:
		var distance = global_position.distance_to(target_zebu.global_position)
		if distance < POUNCE_DISTANCE:
			start_pounce()
	
	# Check pounce on PLAYER
	elif target_player and is_hidden and not is_pouncing and not on_cooldown:
		var distance = global_position.distance_to(target_player.global_position)
		if distance < POUNCE_DISTANCE:
			start_pounce()

func set_target_zebu(zebu):
	target_zebu = zebu
	print("LION: Zebu target set")

func set_target_player(player):
	target_player = player
	print("LION: Player target set")

func set_opacity(value: float):
	if sprite:
		sprite.modulate.a = value
		is_hidden = (value < 1.0)
		print("LION: Opacity set to", value)

func start_pounce():
	if is_pouncing or on_cooldown:
		return
	
	print("LION: Pounce sequence started")
	is_pouncing = true
	
	# Switch to pounce animation
	if pounce_frames:
		sprite.sprite_frames = pounce_frames
		sprite.play("pounce")
		print("LION: Pounce animation loaded")
	
	# Emit warning signal
	emit_signal("lion_pounce_warning")
	print("LION: ⚠️ Warning signal emitted")
	
	# Wait 1.5 seconds
	await get_tree().create_timer(WARNING_TIME).timeout
	
	# POUNCE! Make lion fully visible
	if sprite:
		sprite.modulate.a = 1.0
	
	# Apply damage based on target
	if target_zebu:
		if target_zebu.has_method("take_damage"):
			target_zebu.take_damage(50)
			print("LION: 💥 Pounced on ZEBU - 50% damage")
		else:
			print("LION: 💥 Pounced on ZEBU (damage method TBD)")
	
	if target_player:
		print("LION: 💥 Pounced on PLAYER")
	
	emit_signal("lion_pounced")
	print("LION: 💥 Pounce signal emitted")
	
	# Switch back to walk animation
	if walk_frames:
		sprite.sprite_frames = walk_frames
		sprite.play("walk")
		print("LION: Walk animation restored")
	
	is_pouncing = false
	
	# Start cooldown
	on_cooldown = true
	print("LION: Pounce cooldown started (", POUNCE_COOLDOWN, " seconds)")
	await get_tree().create_timer(POUNCE_COOLDOWN).timeout
	on_cooldown = false
	print("LION: Pounce cooldown ended")
