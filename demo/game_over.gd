extends Node

class_name GameOver

export(PackedScene) var MainManuScene
export(String) var winner_name
export(String) var win_text = "%s wins !!!"


func _ready() -> void:
    var text = win_text % winner_name
    $PlayerLabel.set_text(text)
    

func _on_PlayAgainButton_pressed() -> void:
    get_tree().change_scene_to(MainManuScene)


func _on_QuitButton_pressed() -> void:
    get_tree().quit()
