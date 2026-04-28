extends ProgressBar

func _ready() -> void:
	# 1. Set the bar limits
	min_value = 0.0
	max_value = 100.0
	
	# 2. Look for Amanuel's node in the scene and connect to it
	# This assumes Amanuel's node is named "HeatManager" in the scene tree
	var heat_node = get_tree_root_find_node("HeatManager") 
	
	if heat_node:
		heat_node.thirst_changed_ui.connect(_on_thirst_updated)

# 3. This function runs only when Amanuel's code says the thirst changed
func _on_thirst_updated(new_val: float) -> void:
	value = new_val

# Helper function to find the node anywhere in the game
func get_tree_root_find_node(node_name: String) -> Node:
	return get_tree().root.find_child(node_name, true, false)
