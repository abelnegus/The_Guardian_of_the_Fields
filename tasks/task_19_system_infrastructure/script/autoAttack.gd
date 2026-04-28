extends Node2D

@export var enemy_path: NodePath
@onready var enemy = get_node(enemy_path)

@onready var anim = $AnimationPlayer
@onready var audio = $AudioStreamPlayer2D
@onready var slash_sprite = $"Sprite2D slash"
@onready var melee_area = $Area2D

var attack_range = 96.0  # 1.5 meter distance
var is_attacking = false

func _process(delta):
	if not enemy or is_attacking:
		return

	var dist = global_position.distance_to(enemy.global_position)
	if dist <= attack_range:
		trigger_attack()

func trigger_attack():  #start the animation
	is_attacking = true
	anim.play("attack")
	audio.play()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack":
		is_attacking = false

func _on_MeleeAttack_body_entered(body):
	if body == enemy and body.has_method("take_damage"):
		body.take_damage(10)
