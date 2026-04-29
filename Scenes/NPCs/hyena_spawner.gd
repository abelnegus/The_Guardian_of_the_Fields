extends Node2D

@export var hyena_scene: PackedScene 
var max_hyenas = 4
var spawned_count = 0
var timer = 0.0
var spawn_interval = 50.0 # Requirement: 50 seconds

func _process(delta):
	if spawned_count < max_hyenas:
		timer += delta
		if timer >= spawn_interval:
			spawn_hyena()
			timer = 0.0 # Reset for the next 50-second window

func spawn_hyena():
	var new_hyena = hyena_scene.instantiate()
	get_parent().add_child(new_hyena)
	spawned_count += 1
	print("Hyena spawned. Total: ", spawned_count)
