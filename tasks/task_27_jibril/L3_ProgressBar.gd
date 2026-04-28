extends HeatManager

func _ready() -> void:
	super._ready() # Calls Amanuel's setup logic
	
	# We use set() so Godot doesn't check the type until the game actually starts
	set("min_value", 0.0)
	set("max_value", 100.0)

func _process(delta: float) -> void:
	super._process(delta) # Calls Amanuel's survival math
	
	if state_node:
		set("value", state_node.player_thirst)
