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
const DUST_BROWN = Color(0.65, 0.50, 0.35, 0.9)   # Dusty brown
const DUST_TAN = Color(0.85, 0.75, 0.55, 0.7)     # Sun-lit sand
const DUST_ORANGE = Color(0.90, 0.60, 0.30, 0.6)  # Golden hour dust

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
	print("║  Colors: Brown, Tan, Orange - Savannah sand         ║")
	print("╚══════════════════════════════════════════════════════╝")
	
	# Setup atmospheric haze
	_setup_canvas()
	
	# Setup particle system
	_setup_particles()
	
	# Auto-test sequence
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
	canvas.color = Color(0.55, 0.45, 0.35, 0.6)
	print("✓ Atmospheric haze ready (warm brown)")

func _setup_particles():
	"""Create and configure the particle system"""
	particles = GPUParticles2D.new()
	particles.name = "DustParticles"
	add_child(particles)
	
	# Create colored dust texture
	_create_colored_texture()
	
	# Configure particle system
	particles.amount = 4000
	particles.lifetime = 4.5
	particles.preprocess = 1.5
	particles.explosiveness = 0.0
	particles.randomness = 0.95
	particles.one_shot = false
	particles.fixed_fps = 30
	
	# Position off-screen left (sweeps across)
	particles.position = Vector2(-150, 300)
	
	# Create movement material with color
	_create_movement_material()
	
	print("✓ Particle system configured")
	print("  - 4000 dust grains")
	print("  - Colors: Brown, Tan, Orange")
	print("  - Sweeps from left to right")

func _create_colored_texture():
	"""Create a soft dust grain with color baked in"""
	var size = 8
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	var center = Vector2(size/2, size/2)
	
	for x in range(size):
		for y in range(size):
			var distance = center.distance_to(Vector2(x, y))
			if distance < 3.5:
				# Soft falloff
				var softness = 1.0 - (distance / 3.5)
				softness = softness * softness
				
				# Randomly choose a dust color for variety
				var rand = randf()
				var dust_color: Color
				
				if rand < 0.5:
					dust_color = DUST_BROWN
				elif rand < 0.8:
					dust_color = DUST_TAN
				else:
					dust_color = DUST_ORANGE
				
				dust_color.a = softness * 0.9
				image.set_pixel(x, y, dust_color)
	
	particles.texture = ImageTexture.create_from_image(image)
	print("✓ Colored dust texture created (brown/tan/orange)")

func _create_movement_material():
	"""Create particle material with wind and turbulence"""
	var mat = ParticleProcessMaterial.new()
	
	# ===== EMISSION SHAPE =====
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(40, 450, 40)
	
	# ===== WIND DIRECTION =====
	mat.direction = Vector3(0.95, -0.1, 0)
	mat.spread = 10.0
	mat.flatness = 0.9
	
	# ===== VELOCITY =====
	mat.initial_velocity_min = 80.0
	mat.initial_velocity_max = 200.0
	
	# ===== GRAVITY =====
	mat.gravity = Vector3(0, 12, 0)
	
	# ===== TURBULENCE =====
	mat.turbulence_enabled = true
	mat.turbulence_noise_strength = 3.0
	mat.turbulence_influence_min = 0.2
	mat.turbulence_influence_max = 0.4
	
	# ===== ROTATION =====
	mat.angular_velocity_min = -20.0
	mat.angular_velocity_max = 20.0
	
	# ===== SIZE =====
	mat.scale_min = 0.02
	mat.scale_max = 0.06
	
	# ===== COLOR OVERLAY (Enhances the texture color) =====
	# This adds a warm tint over the particles
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0.85, 0.70, 0.50, 1.0))  # Warm sand
	gradient.add_point(0.5, Color(0.75, 0.60, 0.40, 0.8))  # Dusty
	gradient.add_point(1.0, Color(0.65, 0.50, 0.30, 0.0))   # Fade out
	
	var ramp = GradientTexture1D.new()
	ramp.gradient = gradient
	mat.color_ramp = ramp
	
	particles.process_material = mat

# ============================================================
# WIND VARIATION
# ============================================================

func _process(delta):
	if not is_active:
		return
	
	wind_timer += delta
	if wind_timer > 3.0:
		wind_timer = 0
		_vary_wind()

func _vary_wind():
	"""Randomly adjust wind for natural variation"""
	var mat = particles.process_material
	if not mat:
		return
	
	var variation = randf_range(-30, 40)
	var new_min = clamp(mat.initial_velocity_min + variation, 60, 160)
	var new_max = clamp(mat.initial_velocity_max + variation, 120, 260)
	
	mat.initial_velocity_min = new_min
	mat.initial_velocity_max = new_max
	
	var dir_x = clamp(0.95 + randf_range(-0.08, 0.05), 0.85, 1.0)
	mat.direction = Vector3(dir_x, -0.1, 0)
	
	print("  💨 Wind: ", int(new_min), "-", int(new_max), " px/sec")

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
	tween.tween_property(canvas, "color:a", 0.6, 1.0)
	
	# Start particles
	particles.emitting = true
	
	emit_signal("storm_active")
	print("🌪️ DUST STORM ACTIVATED")
	print("   Brown/Tan dust sweeping across the savannah")

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
# AUTO TEST
# ============================================================

func _auto_test():
	print("")
	print(">>> AUTO-TEST STARTING IN 2 SECONDS...")
	await get_tree().create_timer(2.0).timeout
	
	activate_storm()
	
	await get_tree().create_timer(6.0).timeout
	
	deactivate_storm()
	
	print("")
	print("╔══════════════════════════════════════════════════════╗")
	print("║  TEST COMPLETE                                        ║")
	print("║  Particles should be BROWN/TAN (not black!)          ║")
	print("╚══════════════════════════════════════════════════════╝")

# ============================================================
# PUBLIC API
# ============================================================

func set_intensity(value: float):
	"""Adjust storm intensity (0.0 to 1.0)"""
	if not is_active:
		return
	
	var intensity = clamp(value, 0.2, 1.0)
	particles.amount = int(4000 * intensity)
	canvas.color.a = 0.3 + (intensity * 0.3)

func get_status() -> Dictionary:
	return {
		"active": is_active,
		"particle_count": particles.amount if particles else 0,
		"emitting": particles.emitting if particles else false
	}
