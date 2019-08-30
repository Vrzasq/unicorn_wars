extends Node2D

class_name HpBar

export(int) var max_value
export(bool) var flip = false

var progress_bar : TextureProgress
var hp_label : Label


func _ready() -> void:
    progress_bar = $TextureProgress
    if flip:
        progress_bar.fill_mode = TextureProgress.FILL_RIGHT_TO_LEFT
    hp_label = $Label
    assign_initial_values()
    
    
func assign_initial_values() -> void:
    progress_bar.max_value = max_value
    progress_bar.value = max_value
    hp_label.text = str(max_value)
    

func on_hp_loss(damage_take_args : DamageTakenArgs) -> void:
    progress_bar.value = damage_take_args.target_hp
    hp_label.text = str(damage_take_args.target_hp)