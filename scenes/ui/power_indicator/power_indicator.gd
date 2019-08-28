extends Node2D

class_name PowerIndicator

export(float) var growth_multiplayer = 1

var progress_bar : TextureProgress


func _ready() -> void:
    progress_bar = $TextureProgress
    

func _process(delta: float) -> void:
    _update_progress_bar(delta)
    
        
func _update_progress_bar(delta : float) -> void:
    progress_bar.value += delta * growth_multiplayer
    
    if (progress_bar.value >= progress_bar.max_value \
        || progress_bar.value <= progress_bar.min_value):
        growth_multiplayer *= -1
        
        
func get_power_ratio() -> float:
    return progress_bar.value