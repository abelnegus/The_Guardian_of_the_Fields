extends Area2D

# S-23: Water Source - Afar Water Gourd
# Dependency D-15: Confirmed with S-20 Amanuel
# Location: tasks/task_23_water_source/

@onready var sprite: Sprite2D = $Sprite
@onready var cooldown_timer: Timer = $CooldownTimer

var is_available: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	cooldown_timer.timeout.connect(_on_cooldown_finished)
	_update_sprite()

func _on_body_entered(body: Node2D) -> void:
	if not is_available:
		return
	
	if body.name == "TheGuardian" or body.is_in_group("Guardian"):
		_restore_thirst()

func _restore_thirst() -> void:
	# Per Master Brief S-23: Set Global.player_thirst to 100
	Global.player_thirst = 100.0
	
	# Start 30-second cooldown (Per Master Brief)
	is_available = false
	cooldown_timer.start()
	_update_sprite()
	
	# Play sound if available
	if $DrinkSound:
		$DrinkSound.play()

func _on_cooldown_finished() -> void:
	is_available = true
	_update_sprite()

func _update_sprite() -> void:
	# Path to sprites in your task folder
	var base_path = "res://tasks/task_23_water_source/Sprites/"
	
	var base_tex = load(base_path + "L3_WaterGourd_Base.png")
	var glow_tex = load(base_path + "L3_WaterGourd_Glow.png")
	var empty_tex = load(base_path + "L3_WaterGourd_Empty.png")
	
	if is_available:
		# Show GLOW sprite (ready to use)
		if glow_tex:
			sprite.texture = glow_tex
		else:
			sprite.texture = base_tex
		sprite.modulate = Color(1, 1, 1, 1)
	else:
		# Show EMPTY sprite (on cooldown)
		if empty_tex:
			sprite.texture = empty_tex
		else:
			sprite.texture = base_tex
		sprite.modulate = Color(0.5, 0.5, 0.5, 1)
