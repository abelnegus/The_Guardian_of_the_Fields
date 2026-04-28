extends Node2D

@onready var anim = $AnimationPlayer
@onready var audio = $AudioStreamPlayer2D
@onready var slash_sprite = $"Sprite2D slash"

var attack_range: float = 96.0
var is_attacking: bool = false
var is_invincible: bool = false

func _ready():
	anim.animation_finished.connect(_on_animation_finished)

func _process(delta):
	if is_attacking:
		return

	# Automatically detect enemies in hazard group
	var enemies = get_tree().get_nodes_in_group("hazard")
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist <= attack_range:
			trigger_attack(enemy)
			break

func trigger_attack(enemy):
	is_attacking = true
	is_invincible = true
	anim.play("attack")
	audio.play()

	# Apply damage immediately when attack starts
	if enemy and enemy.has_method("take_damage"):
		enemy.take_damage(10)

func _on_animation_finished(anim_name: StringName):
	if anim_name == "attack":
		is_attacking = false
		is_invincible = false
