extends Node2D

class_name PlayerName

var label : Label


func _ready() -> void:
    label = $Label
    

func set_player_name(var name : String) -> void:
    label.text = name