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
	var active_sprite := _sprite_exposed if phase_two else _sprite_armored
	active_sprite.play("default")
	active_sprite.set_frame_and_progress(0, 0.0)


func get_phase_animation_duration(phase: Variant) -> float:
	if _sprite_armored == null or _sprite_exposed == null:
		return 1.0
	var phase_two: bool = int(phase) != 0
	var active_sprite := _sprite_exposed if phase_two else _sprite_armored
	if active_sprite.sprite_frames == null:
		return 1.0
	var animation_name := StringName("default")
	var frame_count := active_sprite.sprite_frames.get_frame_count(animation_name)
	var animation_speed := active_sprite.sprite_frames.get_animation_speed(animation_name)
	if frame_count <= 0 or animation_speed <= 0.0:
		return 1.0
	return float(frame_count) / animation_speed
