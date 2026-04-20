extends Area2D

var can_interact = false
var on_cooldown = false

func _on_body_entered(body):
	if body.name == "Nole":
		can_interact = true
		print("Press E to reload")

func _on_body_exited(body):
	Ssif body.name == "Nole":
		can_interact = false

func _process(_delta):
	# Requirement: Reload on 'E' key press 
	if can_interact and Input.is_action_just_pressed("interact") and not on_cooldown:
	reload_ammo()

func reload_ammo():
	# Requirement: Set ammo to max [cite: 45, 54]
	Global.current_ammo = Global.max_ammo
	print("Ammo Refilled!")
	
	# Requirement: 10-second cooldown 
	start_cooldown()

func start_cooldown():
	on_cooldown = true
	await get_tree().create_timer(10.0).timeout
	on_cooldown = false
	print("Station ready again")
