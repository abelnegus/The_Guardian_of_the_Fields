# ============================================================
# ARTIST: Kaleab Nigussie (S-15)
# TASK: Realistic Savannah Dust Storm (FINAL)
# BASE: Node - Pure logic management
# FEATURES: Wind-blown, tiny grains, natural turbulence
# ============================================================

extends Node

# Signals for integration
signal storm_active
signal storm_inactive

# Colors from Level 2 Brief
const DUST_MAIN = Color(0.65, 0.50, 0.35, 0.7)   # Dusty brown
const DUST_LIGHT = Color(0.85, 0.75, 0.55, 0.5)  # Sun-lit sand
const DUST_DARK = Color(0.55, 0.40, 0.25, 0.4)   # Shadow sand

var particles: GPUParticles2D
var canvas: CanvasModulate
var is_active: bool = false

# Wind variation variables
var wind_timer: float = 0.0

# ============================================================
# INITIALIZATION
# ============================================================

func _ready():
	print("╔══════════════════════════════════════════════════════╗")
	print("║  S-15: REALISTIC SAVANNAH DUST STORM                ║")
	print("║  Base: Node | Wind-blown particles | Tiny dust      ║")
	print("╚══════════════════════════════════════════════════════╝")
	
	# Setup atmospheric haze
	_setup_canvas()
	
	# Setup particle system
	_setup_particles()
	
	# Auto-test sequence (remove for production)
	_auto_test()

# ============================================================
# SETUP METHODS
# ============================================================

func _setup_canvas():
	"""Create the brown haze atmosphere"""
	canvas = CanvasModulate.new()
	canvas.name = "CanvasModulate"
	add_child(canvas)
	canvas.visible = false
	canvas.color = Color(0.55, 0.45, 0.35, 0.5)
	print("✓ Atmospheric haze ready")

func _setup_particles():
	"""Create and configure the particle system"""
	particles = GPUParticles2D.new()
	particles.name = "DustParticles"
	add_child(particles)
	
	# Create soft dust texture (not blocky!)
	_create_soft_texture()
	
	# Configure particle system
	particles.amount = 3500
	particles.lifetime = 4.5
	particles.preprocess = 1.5
	particles.explosiveness = 0.0
	particles.randomness = 0.95
	particles.one_shot = false
	particles.fixed_fps = 30
	
	# Position off-screen left (sweeps across)
	particles.position = Vector2(-150, 300)
	
	# Create movement material
	_create_movement_material()
	
	print("✓ Particle system configured")
	print("  - 3500 dust grains")
	print("  - Wind speed: 80-200 px/sec")
	print("  - Sweeps from left to right")

func _create_soft_texture():
	"""Create a soft, round dust grain (not blocky)"""
	var size = 8
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	var center = Vector2(size/2, size/2)
	
	for x in range(size):
		for y in range(size):
			var distance = center.distance_to(Vector2(x, y))
			if distance < 3.5:
				# Soft falloff for natural look
				var softness = 1.0 - (distance / 3.5)
				softness = softness * softness
				var alpha = softness * 0.8
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	
	particles.texture = ImageTexture.create_from_image(image)

func _create_movement_material():
	"""Create particle material with wind and turbulence"""
	var mat = ParticleProcessMaterial.new()
	
	# ===== EMISSION SHAPE =====
	# Use a tall box to create a wall of dust off-screen left
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(30, 400, 30)
	
	# ===== WIND DIRECTION =====
	# Sweep from left to right with slight upward angle
	mat.direction = Vector3(0.95, -0.1, 0)
	mat.spread = 8.0  # Narrow for focused sweep
	mat.flatness = 0.9
	
	# ===== VELOCITY (Wind speed) =====
	mat.initial_velocity_min = 80.0
	mat.initial_velocity_max = 180.0
	
	# ===== GRAVITY =====
	# Slight downward pull (realistic sand)
	mat.gravity = Vector3(0, 15, 0)
	
	# ===== TURBULENCE (Natural swirl) =====
	mat.turbulence_enabled = true
	mat.turbulence_noise_strength = 2.5
	mat.turbulence_influence_min = 0.15
	mat.turbulence_influence_max = 0.35
	
	# ===== ROTATION =====
	mat.angular_velocity_min = -15.0
	mat.angular_velocity_max = 15.0
	
	# ===== SIZE (Tiny dust grains!) =====
	# Note: scale_randomness doesn't exist in Godot 4, removed
	mat.scale_min = 0.025
	mat.scale_max = 0.07
	
	# ===== COLOR RAMP (Fade in/out with color) =====
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0, 0, 0, 0))           # Fade in
	gradient.add_point(0.15, DUST_MAIN)                  # Dusty brown
	gradient.add_point(0.4, DUST_LIGHT)                  # Sun-lit tan
	gradient.add_point(0.7, DUST_DARK)                   # Shadow sand
	gradient.add_point(0.9, Color(0.5, 0.35, 0.2, 0.2))  # Fading
	gradient.add_point(1.0, Color(0, 0, 0, 0))           # Fade out
	
	var ramp = GradientTexture1D.new()
	ramp.gradient = gradient
	mat.color_ramp = ramp
	
	particles.process_material = mat

# ============================================================
# WIND VARIATION (Dynamic wind changes)
# ============================================================

func _process(delta):
	if not is_active:
		return
	
	wind_timer += delta
	if wind_timer > 3.0:  # Change wind every 3 seconds
		wind_timer = 0
		_vary_wind()

func _vary_wind():
	"""Randomly adjust wind for natural variation"""
	var mat = particles.process_material
	if not mat:
		return
	
	# Slight random variation in wind speed
	var variation = randf_range(-30, 40)
	var new_min = clamp(mat.initial_velocity_min + variation, 60, 150)
	var new_max = clamp(mat.initial_velocity_max + variation, 120, 250)
	
	mat.initial_velocity_min = new_min
	mat.initial_velocity_max = new_max
	
	# Slight direction variation
	var dir_x = clamp(0.95 + randf_range(-0.05, 0.03), 0.85, 1.0)
	mat.direction = Vector3(dir_x, -0.1, 0)
	
	print("  💨 Wind shifted: ", int(new_min), "-", int(new_max), " px/sec")

# ============================================================
# STORM CONTROL
# ============================================================

func activate_storm():
	"""Start the dust storm"""
	if is_active:
		return
	
	is_active = true
	
	# Activate haze
	canvas.visible = true
	
	# Fade in canvas
	var tween = create_tween()
	tween.tween_property(canvas, "color:a", 0.5, 1.0)
	
	# Start particles
	particles.emitting = true
	
	emit_signal("storm_active")
	print("🌪️ DUST STORM ACTIVATED")
	print("   Wind sweeping left → right")
	print("   Particles should be TINY brown grains")

func deactivate_storm():
	"""Stop the dust storm"""
	if not is_active:
		return
	
	is_active = false
	
	# Fade out haze
	var tween = create_tween()
	tween.tween_property(canvas, "color:a", 0.0, 1.0)
	tween.tween_callback(func(): canvas.visible = false)
	
	# Stop particles
	particles.emitting = false
	
	emit_signal("storm_inactive")
	print("🌤️ DUST STORM DEACTIVATED")

# ============================================================
# AUTO TEST (For verification)
# ============================================================

func _auto_test():
	print("")
	print(">>> AUTO-TEST STARTING IN 2 SECONDS...")
	await get_tree().create_timer(2.0).timeout
	
	activate_storm()
	
	# Let storm run for 6 seconds
	await get_tree().create_timer(6.0).timeout
	
	deactivate_storm()
	
	print("")
	print("╔══════════════════════════════════════════════════════╗")
	print("║  TEST COMPLETE                                        ║")
	print("║  If you saw:                                         ║")
	print("║  - Brown haze over screen                            ║")
	print("║  - Tiny dust grains sweeping left → right            ║")
	print("║  - Natural wind variation                            ║")
	print("║  → YOUR DUST STORM IS WORKING!                       ║")
	print("╚══════════════════════════════════════════════════════╝")

# ============================================================
# PUBLIC API (For integration)
# ============================================================

func set_intensity(value: float):
	"""Adjust storm intensity (0.0 to 1.0)"""
	if not is_active:
		return
	
	var intensity = clamp(value, 0.2, 1.0)
	particles.amount = int(3500 * intensity)
	canvas.color.a = 0.3 + (intensity * 0.3)

func get_status() -> Dictionary:
	"""Return current storm status"""
	return {
		"active": is_active,
		"particle_count": particles.amount if particles else 0,
		"emitting": particles.emitting if particles else false
	}
