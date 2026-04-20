extends Node

var blurCoefficient: float = 0.0
var distortionLevel: float = 0.0
var isDustTriggered: bool = false

func applyDistortionShader(terrain: Node):
    terrain.material.set_shader_param("distortion_level", distortionLevel)

func calculateDistance(player: Node, target: Node) -> float:
    return player.global_position.distance_to(target.global_position)

func applyBlur(target: Node, blur_value: float):
    target.material.set_shader_param("blur_amount", blur_value)

func disableBlurAndDistortion():
    blurCoefficient = 0.0
    distortionLevel = 0.0

func enable_haboob_effect(terrain: Node):
    isDustTriggered = true
    terrain.material.set_shader_param("dust_effect", true)
