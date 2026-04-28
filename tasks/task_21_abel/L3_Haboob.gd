extends GPUParticles2D

# FIX: Added signal for CanvasModulate
signal storm_active

# FIX: Added timer so we don't check every single frame
var fps_check_timer: float = 0.0

func _ready():
	# FIX: Emit signal when the storm begins
	emit_signal("storm_active")

func _process(delta):
	# FIX: Increment timer and only check every 2 seconds
	fps_check_timer += delta
	
	if fps_check_timer >= 2.0:
		fps_check_timer = 0.0 
		
		# FIX: Corrected Logic (Low FPS = Fewer Particles)
		if Engine.get_frames_per_second() < 60:
			amount = 50   
		else:
			amount = 100