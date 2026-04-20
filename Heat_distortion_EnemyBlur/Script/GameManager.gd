extends Node

var is_midday: bool = false
var is_dust: bool = false
var graphics_pipeline: Node

func _ready():
    graphics_pipeline = $GraphicsRenderingPipeline

func detectMidday() -> bool:
    return is_midday

func detectDust() -> bool:
    if is_dust:
        graphics_pipeline.enable_haboob_effect($Terrain)
        return true
    return false

func activateDustEffect():
    is_dust = true
    graphics_pipeline.enable_haboob_effect($Terrain)
