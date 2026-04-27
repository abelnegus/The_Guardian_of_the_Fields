extends CharacterBody2D

# === NODES ===
@onready var sprite = $JackalSprite
@onready var navigation_agent = $NavigationAgent2D
@onready var bite_area = $BiteArea
@onready var flee_timer = $FleeTimer
@onready var bark_sound = $BarkSound

# === STATE ===
enum State { HUNTING, FLEEING }
var current_state = State.HUNTING
var target_camel = null
var flee_direction = Vector2.ZERO
var speed = 120.0
var can_bite = true

# === SIGNALS ===
signal jackal_hit

func _ready():
	current_state = State.HUNTING
	sprite.play("run")
	
	bite_area.body_entered.connect(_on_bite_area_entered)
	flee_timer.timeout.connect(_on_flee_timeout)
	
	await get_tree().create_timer(0.5).timeout
	find_nearest_camel()
	
	_play_bark()

func _physics_process(delta):
	match current_state:
		State.HUNTING:
			_hunt(delta)
		State.FLEEING:
			_flee(delta)

func _hunt(_delta):
	if target_camel == null or not is_instance_valid(target_camel):
		find_nearest_camel()
		if target_camel == null:
			return
	
	var direction = global_position.direction_to(target_camel.global_position)
	velocity = direction * speed
	move_and_slide()
	
	navigation_agent.target_position = target_camel.global_position
	
	if direction.x != 0:
		sprite.flip_h = direction.x < 0

func find_nearest_camel():
	var closest_distance = INF
	var closest_camel = null
	
	var camels = get_tree().get_nodes_in_group("caravan_camels")
	
	for camel in camels:
		var dist = global_position.distance_to(camel.global_position)
		if dist < closest_distance:
			closest_distance = dist
			closest_camel = camel
	
	if closest_camel != null and closest_camel != target_camel:
		target_camel = closest_camel
		_play_bark()

func _on_bite_area_entered(body):
	if current_state != State.HUNTING:
		return
	if not can_bite:
		return
	
	if body.is_in_group("caravan_camels"):
		can_bite = false
		
		sprite.play("bite")
		await sprite.animation_finished
		sprite.play("run")
		
		if body.has_method("on_jackal_bite"):
			body.on_jackal_bite()
		
		await get_tree().create_timer(1.5).timeout
		can_bite = true

func hit_by_gile():
	if current_state == State.FLEEING:
		return
	
	current_state = State.FLEEING
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		flee_direction = (global_position - player.global_position).normalized()
	else:
		flee_direction = Vector2.RIGHT
	
	sprite.play("flee")
	
	_play_bark()
	
	jackal_hit.emit()
	flee_timer.start(5.0)

func _flee(_delta):
	velocity = flee_direction * speed * 1.5
	move_and_slide()

func _on_flee_timeout():
	current_state = State.HUNTING
	sprite.play("run")
	find_nearest_camel()
	_play_bark()

func die():
	queue_free()

func _play_bark():
	if bark_sound and bark_sound.stream:
		bark_sound.pitch_scale = randf_range(0.8, 1.2)
		bark_sound.play()
