extends Area2D

func _ready():
	# Connect the signal so the bottle knows it's being touched
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the player touched it
	if body.is_in_group("player"):
		# Turn on the 15-second buff for S-11 (Kaleab S.)
		Global.cheka_active = true
		print("Cheka Buff Started!")

		# Wait 15 seconds, then run the 'stop_buff' function
		get_tree().create_timer(15.0).timeout.connect(stop_buff)
		
		# Hide the bottle so it looks like it was picked up
		visible = false
		$CollisionShape2D.set_deferred("disabled", true)

func stop_buff():
	# Turn off the buff
	Global.cheka_active = false
	print("Cheka Buff Ended.")
	queue_free() # Delete the bottle from the game
