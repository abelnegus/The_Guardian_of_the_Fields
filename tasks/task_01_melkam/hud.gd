extends CanvasLayer

func _process(delta):
	# --- TEST LOGIC: These lines will make the bars drain automatically ---
	Global.herd_integrity -= 5.0 * delta
	Global.current_ammo = int(Global.herd_integrity / 10)
	
	# --- REAL HUD LOGIC ---
	$IntegrityBar.value = Global.herd_integrity
	$AmmoBar.value = Global.current_ammo
	
	# Reset the test when it hits zero
	if Global.herd_integrity <= 0:
		Global.herd_integrity = 100.0
