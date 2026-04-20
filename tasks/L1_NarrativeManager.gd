extends Control

# --- STORY DATA (UC-L1-06 & UC-L1-13) ---
var story_steps = [
	"The harvest is tomorrow, but the fields are under siege. Protect our lifeblood! If this field falls, the village starves.",
	"The Alpha Baboon lets out a final grunt and collapses. The village is safe, but your victory is short-lived...",
	"'Shepherd with the Golden Arm!' a voice cries out. 'The predators are slaughtering our Zebu herds! Please, help us!'"
]

var names = [
	"ATO TESSEMA", 
	"DEFEATED 
	 ALPHA", 
	"EXHAUSTED 
	MERCHANT"
]

# CRITICAL: Verify these paths match your FileSystem exactly!
var portraits = [
	"res://tasks/task_09_ayyub/Assets/Tessema_Portrait.png",
	"res://tasks/task_09_ayyub/Assets/Defeated_Alpha.png",
	"res://tasks/task_09_ayyub/Assets/Exhausted_Merchant.png"
]

# --- LOGIC VARIABLES ---
var current_step: int = 0
var full_text: String = ""
var current_index: int = 0
var is_typing: bool = false
var next_level_path = "res://Scenes/Levels/L2_Savannah.tscn"

# --- REFERENCES ---
@onready var background_dimmer = $CanvasLayer/BackgroundDimmer
@onready var dialogue_box = $CanvasLayer/DialogueBox
@onready var text_label = $CanvasLayer/DialogueBox/TextLabel
@onready var next_arrow = $CanvasLayer/DialogueBox/NextArrow
@onready var portrait_node = $CanvasLayer/DialogueBox/Portrait
@onready var name_label = $CanvasLayer/DialogueBox/NameLabel
@onready var typing_timer = $TypingTimer

func _ready():
	typing_timer.timeout.connect(_on_typing_timer_timeout)
	typing_timer.wait_time = 0.05
	typing_timer.one_shot = false
	
	dialogue_box.hide()
	background_dimmer.hide()
	
	start_narrative()

func start_narrative():
	background_dimmer.show()
	dialogue_box.show()
	update_visuals() # Set the first face and name
	play_message(story_steps[current_step])

func update_visuals():
	# This line "loads" the new picture into the old Portrait node
	portrait_node.texture = load(portraits[current_step])
	# This line updates the name text
	name_label.text = names[current_step]

func play_message(text: String) -> void:
	full_text = text
	current_index = 0
	text_label.text = ""
	is_typing = true
	next_arrow.show() 
	typing_timer.start()

func _on_typing_timer_timeout():
	if current_index < full_text.length():
		text_label.text += full_text[current_index]
		current_index += 1
	else:
		finish_typing()

func finish_typing():
	is_typing = false
	typing_timer.stop()

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_typing:
			# One-click skip typing
			text_label.text = full_text
			current_index = full_text.length()
			finish_typing()
		else:
			advance_story()

func advance_story():
	current_step += 1
	if current_step < story_steps.size():
		update_visuals() # Swap to the next face/name
		play_message(story_steps[current_step])
	else:
		change_level()

func change_level():
	background_dimmer.hide()
	dialogue_box.hide()
	if FileAccess.file_exists(next_level_path):
		get_tree().change_scene_to_file(next_level_path)
	else:
		# Narrative is finished.
		self.hide()
