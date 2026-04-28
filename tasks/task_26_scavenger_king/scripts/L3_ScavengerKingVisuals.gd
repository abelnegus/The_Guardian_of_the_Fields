extends Node2D
class_name L3_ScavengerKingVisuals
## Phase 1 = armored, Phase 2 = exposed (visibility swap between animations).

var _sprite_armored: AnimatedSprite2D
var _sprite_exposed: AnimatedSprite2D


func _ready() -> void:
	_sprite_armored = get_node_or_null("SpritePhase1") as AnimatedSprite2D
	_sprite_exposed = get_node_or_null("SpritePhase2") as AnimatedSprite2D
	if _sprite_armored == null or _sprite_exposed == null:
		push_error("L3_ScavengerKingVisuals: expected child nodes SpritePhase1 and SpritePhase2.")
		return
	_sprite_armored.play("default")
	_sprite_exposed.play("default")


func set_phase(phase: Variant) -> void:
	if _sprite_armored == null or _sprite_exposed == null:
		return
	var phase_two: bool = int(phase) != 0
	_sprite_armored.visible = not phase_two
	_sprite_exposed.visible = phase_two
