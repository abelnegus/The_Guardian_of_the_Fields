extends CanvasLayer

# =========================
# UI REFERENCES
# =========================
@onready var warning_icon = $WarningIcon

# =========================
# RUNTIME REFERENCES
# =========================
var lion: Node = null

# Prevent overlapping / spam warnings
var warning_active: bool = false
var debug_lock: bool = false

# Particle scene (if you still use rustle effect)
const GRASS_RUSTLE_SCENE = preload("res://Scenes/level2/GrassRustle1.tscn")


# =========================
# READY
# =========================
func _ready():
	warning_icon.visible = false
	_connect_lion()


# =========================
# CONNECT LION SAFELY
# =========================
func _connect_lion():
	lion = get_tree().get_first_node_in_group("lion")

	if not lion:
		push_error("Lion not found in scene tree!")
		return

	# Avoid duplicate signal connections
	if lion.lion_pounce_warning.is_connected(on_lion_pounce_warning):
		lion.lion_pounce_warning.disconnect(on_lion_pounce_warning)

	lion.lion_pounce_warning.connect(on_lion_pounce_warning)


# =========================
# SHOW / HIDE UI
# =========================
func show_warning():
	warning_icon.visible = true


func hide_warning():
	warning_icon.visible = false


# =========================
# MAIN SIGNAL HANDLER
# =========================
func on_lion_pounce_warning(position: Vector2):

	# Prevent spam or overlapping triggers
	if debug_lock:
		return

	debug_lock = true
	warning_active = true

	print("WARNING START")

	show_warning()
	spawn_grass_particles(position)

	# Safe fallback timing
	var wait_time := 1.5
	if lion and lion.has_method("get_warning_time"):
		wait_time = lion.get_warning_time()

	# Safe timer (ignores pause issues)
	await get_tree().create_timer(wait_time, false, true).timeout

	hide_warning()

	print("WARNING END")

	warning_active = false
	debug_lock = false


# =========================
# GRASS RUSTLE EFFECT
# =========================
func spawn_grass_particles(position: Vector2):

	if not GRASS_RUSTLE_SCENE:
		push_error("GrassRustle scene missing!")
		return

	var rustle = GRASS_RUSTLE_SCENE.instantiate()

	var root = get_tree().current_scene
	if root:
		root.add_child(rustle)
	else:
		get_tree().root.add_child(rustle)

	rustle.global_position = position

	if rustle.has_method("restart"):
		rustle.restart()


# =========================
# DEBUG TEST INPUT
# =========================
func _input(event):
	if OS.is_debug_build() and event.is_action_pressed("ui_accept"):
		on_lion_pounce_warning(Vector2(300, 200))


# =========================
# SAFETY RESET
# =========================
func _exit_tree():
	warning_active = false
	debug_lock = false
