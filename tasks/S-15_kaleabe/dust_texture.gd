extends Node

## Creates a soft, round, yellowish-brown dust particle texture
static func create() -> ImageTexture:
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	var center = Vector2(7.5, 7.5)
	
	for x in range(16):
		for y in range(16):
			var distance = center.distance_to(Vector2(x, y))
			if distance < 6.0:
				var softness = 1.0 - (distance / 6.0)
				softness = softness * softness
				var alpha = softness * 0.7 * (0.6 + randf() * 0.6)
				# Warm savannah sand colors
				var r = 0.85 + randf() * 0.15
				var g = 0.65 + randf() * 0.12
				var b = 0.40 + randf() * 0.10
				image.set_pixel(x, y, Color(r, g, b, alpha))
	
	# Add fine specks for texture
	for i in range(60):
		var x = randi() % 16
		var y = randi() % 16
		var alpha = 0.2 + randf() * 0.5
		image.set_pixel(x, y, Color(0.9, 0.75, 0.55, alpha))
	
	return ImageTexture.create_from_image(image)

func _ready():
	print("S-15: Dust texture generator loaded")
