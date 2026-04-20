extends Area2D

# --- VARIABLES ---
var speed: float = 100.0
var stagger_duration: float = 1.5
var is_carrying_teff: bool = false
var collision_detected: bool = false
var hp: int = 10 # Nole's stone does damage, so we need health!

var spawn_point: Vector2
var target_position: Vector2

# Grab our nodes
@onready var grunt_audio = $GruntAudio
@onready var anim_sprite = $AnimatedSprite2D

func _ready():
	# CONTRACT D-02: Add to hazard group for Ermias's Teff Field
	add_to_group("hazard")
	
	# S-3 REQUIREMENT: Randomize pitch so baboons sound different
	grunt_audio.pitch_scale = randf_range(0.8, 1.2)
	
	# Set up initial spawn
	spawn_point = global_position
	
	# Start walking!
	anim_sprite.play("walk")
	
	# --- ADD THIS MISSING LINE! ---
	# TEMP SANDBOX HACK: Target the Marker2D
	#target_position = get_parent().get_node("Marker2D").global_position

func _physics_process(delta):
	# CONTRACT D-03: Listen for Mebratu's Alpha Boss Enrage state
	var current_speed = speed
	if Global.boss_enraged:
		current_speed *= 1.5
		anim_sprite.speed_scale = 1.5 # Animate faster!
	else:
		anim_sprite.speed_scale = 1.0
		
	# 1. STAGGER STATE (Hit by Wenchif)
		
	# 2. APPROACH / ESCAPE LOGIC
	if target_position != Vector2.ZERO:
		# Tell the NavigationAgent where we want to go
		$NavigationAgent2D.target_position = target_position
		
		# Ask the NavigationAgent for the exact next step
		var next_path_pos = $NavigationAgent2D.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
		
		# AREA2D MOVEMENT FIX: Move by directly updating global_position
		global_position += direction * current_speed * delta
		
		# Flip the sprite depending on which way we are walking
		if direction.x < 0:
			anim_sprite.flip_h = true
		else:
			anim_sprite.flip_h = false

# This function will be called by Ermias's Teff Field when we steal!
func steal_crop():
	is_carrying_teff = true
	target_position = spawn_point # Turn around and run away
	grunt_audio.play() # Grunt triumphantly!
	# Nole's Stone will call this function when it hits the baboon
	
func take_damage(amount: int):
	hp -= amount

	# If health drops to 0 or below, the baboon dies
	if hp <= 0:
		queue_free() 
		return
		
	# Trigger Stagger State (Pause movement)
	collision_detected = true
	anim_sprite.play("idle")

	# Wait for the stagger duration
	await get_tree().create_timer(stagger_duration).timeout

	# Resume walking!
	collision_detected = false
	anim_sprite.play("walk")
