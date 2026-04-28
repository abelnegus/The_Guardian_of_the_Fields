extends Camera2D
## When `L3_ScavengerKing.tscn` is the run root (F6), center the view. When instanced under a level, stays off.


func _ready() -> void:
	call_deferred("_try_activate_preview")


func _try_activate_preview() -> void:
	var scene_root := get_tree().current_scene
	if scene_root == null or get_parent() != scene_root:
		return
	var king: Node2D = scene_root.get_node_or_null("KingBody") as Node2D
	if king:
		global_position = king.global_position + Vector2(96.0, 132.0)
	else:
		position = Vector2(96.0, 132.0)
	zoom = Vector2(3.5, 3.5)
	enabled = true
	make_current()
