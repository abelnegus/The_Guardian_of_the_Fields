# ============================================================
# S-15: FRIENDLY FIRE SYSTEM
# Author: Kaleabe N.
# When arrow hits Zebu: -15 points + red flash + flinch
# ============================================================

extends Node

# Signals for integration
signal friendly_fire_triggered(zebu_node, penalty_amount)
signal zebu_hit_sound(zebu_node)

# Constants from Master Brief
const ZEBU_COLLISION_LAYER: int = 2  # Layer 2 per D-10 with S-10
const PENALTY_AMOUNT: int = 15       # 15 point penalty per Master Brief
const FLASH_DURATION: float = 0.15   # Red flash duration

# Reference to Global score system
var global_ref = null

# ============================================================
# INITIALIZATION
# ============================================================

func _ready():
	print("╔══════════════════════════════════════════════════════╗")
	print("║  S-15: FRIENDLY FIRE SYSTEM READY                   ║")
	print("║  Penalty: -", PENALTY_AMOUNT, " points per Zebu hit     ║")
	print("║  Collision Layer: ", ZEBU_COLLISION_LAYER, " (D-10 with S-10)  ║")
	print("╚══════════════════════════════════════════════════════╝")
	
	# Find Global.gd (autoload) for score management
	_find_global_reference()
	
	# Connect to arrow signals (S-11 will provide this)
	_connect_to_arrows()

# ============================================================
# CONNECTION METHODS
# ============================================================

func _find_global_reference():
	"""Find the Global autoload for score management"""
	if has_node("/root/Global"):
		global_ref = get_node("/root/Global")
		print("✓ Connected to Global score system")
	else:
		print("⚠ Global.gd not found - will use fallback score")
		global_ref = null

func _connect_to_arrows():
	"""Connect to arrow collision signals from S-11"""
	# This will be connected when S-11's arrow system is ready
	# For now, we'll wait for the signal connection
	print("✓ Waiting for arrow collision signals from S-11")
	print("  - Expected signal: arrow_hit(area: Area2D)")

# ============================================================
# MAIN FRIENDLY FIRE HANDLER
# ============================================================

func on_arrow_hit(hit_area: Area2D):
	"""
	Called when an arrow hits something.
	Should be connected to S-11's arrow_hit signal.
	"""
	# Check if we hit a Zebu (Layer 2)
	if hit_area.collision_layer & (1 << (ZEBU_COLLISION_LAYER - 1)):
		_handle_friendly_fire(hit_area)

func _handle_friendly_fire(zebu: Area2D):
	"""Process friendly fire when Zebu is hit"""
	print("")
	print("⚠⚠⚠ FRIENDLY FIRE DETECTED ⚠⚠⚠")
	print("  Target: Zebu on Layer ", ZEBU_COLLISION_LAYER)
	
	# 1. Apply score penalty
	_apply_score_penalty()
	
	# 2. Apply visual feedback
	_apply_red_flash(zebu)
	
	# 3. Trigger flinch animation
	_trigger_flinch(zebu)
	
	# 4. Show penalty message
	_show_penalty_message()
	
	# 5. Emit signal for other systems
	emit_signal("friendly_fire_triggered", zebu, PENALTY_AMOUNT)
	
	print("  Penalty applied: -", PENALTY_AMOUNT, " points")
	print("⚠ Friendly fire processed")

# ============================================================
# PENALTY METHODS
# ============================================================

func _apply_score_penalty():
	"""Apply the score penalty to Global.score or fallback"""
	if global_ref and global_ref.has("score"):
		global_ref.score -= PENALTY_AMOUNT
		print("  ✓ Score updated: ", global_ref.score, " (-", PENALTY_AMOUNT, ")")
	else:
		print("  ⚠ Global.score not available - penalty not applied")
		
		# Optional: Create local counter for testing
		if not has_meta("test_score"):
			set_meta("test_score", 100)
		var current = get_meta("test_score")
		set_meta("test_score", current - PENALTY_AMOUNT)
		print("  → Test score: ", get_meta("test_score"), " (fallback)")

# ============================================================
# VISUAL EFFECTS
# ============================================================

func _apply_red_flash(zebu: Area2D):
	"""Apply red flash effect to the hit Zebu"""
	var sprite = _find_sprite(zebu)
	
	if sprite:
		# Store original color
		var original_color = sprite.modulate
		
		# Create tween for red flash
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.RED, FLASH_DURATION)
		tween.tween_property(sprite, "modulate", original_color, FLASH_DURATION)
		print("  ✓ Red flash applied to Zebu")
	else:
		print("  ⚠ Could not find sprite for red flash")

func _trigger_flinch(zebu: Area2D):
	"""Trigger flinch animation on Zebu"""
	var anim_player = _find_animation_player(zebu)
	
	if anim_player and anim_player.has_animation("flinch"):
		anim_player.play("flinch")
		print("  ✓ Flinch animation triggered")
	elif anim_player:
		# If no flinch animation, try default
		print("  ⚠ No 'flinch' animation found on Zebu")
	else:
		print("  ⚠ No AnimationPlayer found on Zebu")

func _show_penalty_message():
	"""Show penalty message (for UI system)"""
	# This will be picked up by the UI system (S-1 or S-27)
	print('  ✓ Penalty message: "Friendly Fire! -', PENALTY_AMOUNT, '"')
	
	# Emit signal for UI
	emit_signal("zebu_hit_sound", null)

# ============================================================
# HELPER METHODS
# ============================================================

func _find_sprite(node: Node) -> Sprite2D:
	"""Find Sprite2D in node hierarchy"""
	if node is Sprite2D:
		return node
	
	for child in node.get_children():
		var found = _find_sprite(child)
		if found:
			return found
	
	return null

func _find_animation_player(node: Node) -> AnimationPlayer:
	"""Find AnimationPlayer in node hierarchy"""
	if node is AnimationPlayer:
		return node
	
	for child in node.get_children():
		var found = _find_animation_player(child)
		if found:
			return found
	
	return null

# ============================================================
# PUBLIC API
# ============================================================

func set_score_penalty(amount: int):
	"""Change the penalty amount (if manager requests)"""
	# This would need manager approval per guidelines
	print("⚠ Penalty change requested from ", PENALTY_AMOUNT, " to ", amount)
	print("  → Coordinate with manager before changing")

func get_penalty_amount() -> int:
	"""Return current penalty amount"""
	return PENALTY_AMOUNT

func get_test_score() -> int:
	"""Get test score (for debugging)"""
	if get_meta("test_score"):
		return get_meta("test_score")
	return -1

# ============================================================
# TEST MODE (For standalone testing)
# ============================================================

func _test_friendly_fire():
	"""Simulate a Zebu hit for testing without arrows"""
	print("")
	print(">>> TEST MODE: Simulating Zebu hit...")
	
	# Create a mock Zebu Area2D for testing
	var mock_zebu = Area2D.new()
	mock_zebu.name = "MockZebu"
	mock_zebu.collision_layer = 1 << (ZEBU_COLLISION_LAYER - 1)
	
	# Add a mock sprite for visual feedback
	var mock_sprite = Sprite2D.new()
	mock_sprite.name = "ZebuSprite"
	
	# Create a simple rectangle texture
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.85, 0.65, 0.35, 1.0))
	mock_sprite.texture = ImageTexture.create_from_image(image)
	
	mock_zebu.add_child(mock_sprite)
	
	# Handle the mock hit
	_handle_friendly_fire(mock_zebu)
	
	print(">>> Test complete - Mock Zebu destroyed")
