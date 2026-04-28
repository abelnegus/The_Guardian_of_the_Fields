extends Node
class_name HeatManager

# DEPENDENCIES (Clean Architecture)
# =========================
@export_group("Dependencies")
## The node containing player_thirst and herd_integrity. 
## If left null, the manager will attempt to resolve "/root/Global" at runtime.
@export var state_node: Node 

# CONFIGURATION
# =========================
@export_group("Survival Settings")
@export var thirst_decay_rate: float = 2.0          # per second
@export var herd_damage_rate: float = 5.0           # per second when thirst == 0

@export_group("Audio Settings")
@export var low_thirst_threshold: float = 30.0      # heartbeat trigger threshold

# SIGNALS 
# =========================
signal thirst_changed(value: float)         
signal thirst_changed_ui(value: float)      
signal thirst_depleted()                    

# NODE REFERENCES
# =========================
@onready var heartbeat_sfx: AudioStreamPlayer2D = $HeartbeatSFX

# INTERNAL STATE
# =========================
var _was_depleted: bool = false
var _thirst_tick_accumulator: float = 0.0
const TICK_RATE: float = 0.1  

const AUDIO_ENTER_THRESHOLD: float = 30.0
const AUDIO_EXIT_THRESHOLD: float = 32.0
var _audio_active: bool = false

# LIFECYCLE
# =========================
func _ready() -> void:
	# Fallback for Autoload environment if DI is not passed via Inspector
	if not state_node:
		state_node = get_node_or_null("/root/Global")
		
	_validate_dependencies()
	_validate_config()
	_initialize_audio()

func _process(delta: float) -> void:
	if not state_node: return # Safety check
		
	_thirst_tick_accumulator += delta
	
	while _thirst_tick_accumulator >= TICK_RATE:
		_thirst_tick_accumulator -= TICK_RATE
		_update_thirst(TICK_RATE)
		_apply_herd_penalty(TICK_RATE)
	
	_update_audio()

# CORE LOGIC
# =========================
func _update_thirst(delta: float) -> void:
	state_node.player_thirst = clampf(state_node.player_thirst, 0.0, 100.0)
	var previous: float = state_node.player_thirst
	
	state_node.player_thirst = clampf(
		state_node.player_thirst - (thirst_decay_rate * delta),
		0.0,
		100.0
	)

	if not is_equal_approx(previous, state_node.player_thirst):
		thirst_changed.emit(state_node.player_thirst)

	if floor(previous) != floor(state_node.player_thirst):
		thirst_changed_ui.emit(state_node.player_thirst)

	if state_node.player_thirst <= 0.0 and not _was_depleted:
		_was_depleted = true
		thirst_depleted.emit()
	elif state_node.player_thirst > 0.0:
		_was_depleted = false

func _apply_herd_penalty(delta: float) -> void:
	if state_node.player_thirst <= 0.0:
		state_node.herd_integrity = max(
			state_node.herd_integrity - (herd_damage_rate * delta),
			0.0
		)

# AUDIO SYSTEM 
# =========================
func _update_audio() -> void:
	if not heartbeat_sfx or not state_node:
		return
		
	if not _audio_active and state_node.player_thirst < AUDIO_ENTER_THRESHOLD:
		_audio_active = true
	elif _audio_active and state_node.player_thirst > AUDIO_EXIT_THRESHOLD:
		_audio_active = false

	if _audio_active:
		var safe_threshold: float = max(low_thirst_threshold, 0.01)
		var intensity: float = 1.0 - (state_node.player_thirst / safe_threshold)
		intensity = clampf(intensity, 0.0, 1.0)

		heartbeat_sfx.pitch_scale = lerp(1.0, 1.8, intensity)

		if not heartbeat_sfx.playing:
			heartbeat_sfx.play()
	else:
		if heartbeat_sfx.playing:
			heartbeat_sfx.stop()

func _initialize_audio() -> void:
	if heartbeat_sfx:
		heartbeat_sfx.stop()
		heartbeat_sfx.pitch_scale = 1.0

# VALIDATION 
# =========================
func _validate_dependencies() -> void:
	if not state_node:
		push_error("HeatManager: state_node is null. Dependency Injection failed and Global fallback not found.")
		return

	if not "player_thirst" in state_node:
		push_error("HeatManager: state_node is missing 'player_thirst' property.")

	if not "herd_integrity" in state_node:
		push_error("HeatManager: state_node is missing 'herd_integrity' property.")

func _validate_config() -> void:
	if low_thirst_threshold <= 0.0:
		push_error("HeatManager: low_thirst_threshold must be > 0.0")
