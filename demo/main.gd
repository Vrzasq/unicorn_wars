extends Node

export(PackedScene) var GameScene : PackedScene

func _on_StartGameButton_pressed() -> void:
    load_game_scene()

func load_game_scene() -> void:
    var tree : SceneTree = get_tree()
    tree.root.remove_child(self)
    self.call_deferred("free")
    
    var game = GameScene.instance()
    
    if game is DemoManager:
        game.player1_name = $VBoxContainer/Player1Name.text
        game.player2_name = $VBoxContainer/Player2Name.text
        
    tree.root.add_child(game)