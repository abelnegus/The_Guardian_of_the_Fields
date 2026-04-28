extends PathFollow2D

var Speed = 0.1
var last_position: Vector2

# Adjust the path to your AnimatedSprite2D node
@onready var sprite =  $AnimatedSprite2D
func _ready() -> void:
	last_position = global_position

func _process(delta: float) -> void:
	progress_ratio += delta * Speed
	
	var current_position = global_position
	var direction = current_position - last_position
	
	if direction.length() > 0.1:
		rotation = direction.angle()
		
		# --- THE FIX ---
		# If the angle is pointing left (between 90 and 270 degrees),
		# flip the sprite vertically so it stays upright.
		if abs(rotation) > PI / 2:
			sprite.flip_v = true
		else:
			sprite.flip_v = false
			
	last_position = current_position
