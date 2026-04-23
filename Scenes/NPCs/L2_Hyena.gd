extends CharacterBody2D

# Stats
var health = 150 
var base_speed = -100.0 # Moving Left

# Zigzag Variables
var time_passed = 0.0
var amplitude = 300.0  # How far up/down it goes
var frequency = 5.0    # How fast it zig-zags
var erratic_timer = 0.0

func _ready():
	add_to_group("enemies") 
	
	# REQUIREMENT: Twice as big
	self.scale = Vector2(2, 2)
	
	# REQUIREMENT: Start right, outside screen
	setup_starting_position()
	
	# Randomize initial erratic values so they don't all move the same
	randomize_movement()

func setup_starting_position():
	var screen_width = get_viewport_rect().size.x
	var screen_height = get_viewport_rect().size.y
	
	# ADJUST THIS VALUE: 
	# 0.9 means 90% of the way down the screen (the "ground").
	# If they are too low, change 0.9 to 0.8 or 0.85.
	var ground_y_position = screen_height * 0.7
	
	# Add a tiny bit of random variation so they aren't in a perfect line
	var small_variation = randf_range(-20, 20)
	
	global_position = Vector2(screen_width + 150, ground_y_position + small_variation)

# IMPORTANT: To prevent the hyena from flying into the sky or digging 
# into the floor while zigzagging, we must lower the amplitude.
func randomize_movement():
	# Lower amplitude (30-60) keeps them on the "ground plane" 
	# while still looking erratic.
	amplitude = randf_range(30.0, 60.0) 
	frequency = randf_range(3.0, 7.0)

func _physics_process(delta):
	time_passed += delta
	erratic_timer += delta
	
	# REQUIREMENT: Erratic switching
	# Every 1.5 seconds, change the zigzag pattern slightly
	if erratic_timer >= 1.5:
		randomize_movement()
		erratic_timer = 0.0

	# REQUIREMENT: Zigzag movement using Sin function
	# X is constant movement toward Zebu
	# Y uses Sin for the "up and down" zigzag
	velocity.x = base_speed
	velocity.y = cos(time_passed * frequency) * amplitude
	
	# Move and handle collisions
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var target = collision.get_collider()
		if target.is_in_group("zebu"):
			Global.herd_integrity -= 10.0 * delta

func take_damage(amount):
	health -= amount
	modulate = Color(5, 0, 0) # Flash Red
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	
	if health <= 0:
		queue_free()
		

#
#var health = 150 
#var base_speed = -180.0
#var ground_y = 0.0
#
## Lunge Variables
#var time_passed = 0.0
#var jump_height = 150.0  
#var jump_speed = 5.0    
#var erratic_timer = 0.0
#
#func _ready():
	#add_to_group("enemies") 
	#self.scale = Vector2(2, 2) # Twice as big
	#setup_starting_position()
#
#func setup_starting_position():
	#var screen_width = get_viewport_rect().size.x
	#var screen_height = get_viewport_rect().size.y
	## Ground position at 90% screen height
	#ground_y = screen_height * 0.9 
	#global_position = Vector2(screen_width + 150, ground_y)
#
#func _physics_process(delta):
	#time_passed += delta
	#erratic_timer += delta
	#
	## Randomize jump height/speed every 2 seconds for erratic zigzag feel
	#if erratic_timer >= 2.0:
		#jump_height = randf_range(100.0, 250.0)
		#jump_speed = randf_range(4.0, 7.0)
		#erratic_timer = 0.0
#
	## X Movement: Constantly toward Zebu
	#velocity.x = base_speed
	#
	## Y Movement: The "Jump Zigzag"
	## abs(sin) creates the "bounce" off the ground
	#var jump_arc = abs(sin(time_passed * jump_speed)) * jump_height
	#global_position.y = ground_y - jump_arc
	#
	## Handle Collisions
	##var collision = move_and_collide(velocity * delta)
	##if collision:
		##var target = collision.get_collider()
		##if target.is_in_group("zebu"):
			##Global.herd_integrity -= 10.0 * delta
#
#func take_damage(amount):
	#health -= amount
	#modulate = Color(5, 0, 0) # Flash Red
	#await get_tree().create_timer(0.1).timeout
	#modulate = Color(1, 1, 1)
	#if health <= 0:
		#queue_free()
		#
		#
		#
		#
		#
