extends Node2D

class_name RainbowLabel

export(String) var text = "Hello There"
export(Theme) var theme

var label : Label

func _ready() -> void:
    label = $Label
    label.text = text
    if theme:
        $Label.theme = theme
    

func set_text(var name : String) -> void:
    label.text = name