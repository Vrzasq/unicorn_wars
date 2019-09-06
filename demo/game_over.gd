extends Node

export(String) var winner_name
export(String) var win_text = "%s wins !!!"


func _ready() -> void:
    var text = win_text % winner_name
    $PlayerLabel.set_text(text)
    

func _on_PlayAgainButton_pressed() -> void:
    var tree : SceneTree = get_tree()
    tree.root.remove_child(self)
    self.call_deferred("free")
    
    var main_scene = load("res://demo/main.tscn").instance()
    tree.root.add_child(main_scene)


func _on_QuitButton_pressed() -> void:
    get_tree().quit()
