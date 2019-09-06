extends Node2D

class_name DemoManager

export(String) var player1_name = "Player1"
export(String) var player2_name = "Player2"

var players = {}
var current_player : Player
var player_name_display : RainbowLabel

func _ready() -> void:
    player_name_display = $HUD/PlayerName
    assign_players()
    choose_statring_player()
    # print(current_player.display_name)
    get_tree().paused = true


func assign_players() -> void:
    var all_players := get_tree().get_nodes_in_group("players")
    
    for player in all_players:
        players[player.name] = player
        player.connect("turn_end", self, "on_player_turn_end")
        player.connect("died", self, "on_player_died")
    
    set_player_name(players.Player1, player1_name)
    set_player_name(players.Player2, player2_name)
    

func choose_statring_player() -> void:
    randomize()
    var rand = randi() % 2
    
    if rand == 0:
        current_player = players.Player1
    else:
        current_player = players.Player2
    
    current_player.start_turn()
    set_current_player_name()
    
    
func on_player_turn_end(other_player : Player) -> void:
    # print(other_player.name)
    current_player.end_turn()
    current_player.reset_position()
    other_player.start_turn()
    other_player.reset_position()
    current_player = other_player
    set_current_player_name()
    
    
func set_player_name(player : Player, name : String) -> void:
    if name != "":
        player.display_name = name
    else:
        player.display_name = player.name
    
    
func set_current_player_name() -> void:
    player_name_display.set_text(current_player.display_name)


func _on_GameStartTimer_timeout() -> void:
    get_tree().paused = false
    $GameStartTimer.queue_free()
    
    
func on_player_died(winner_player : Player) -> void:
    show_game_over_scene(winner_player)
 

func show_game_over_scene(winner_player : Player) -> void:
    var tree : SceneTree = get_tree()
    tree.root.remove_child(self)
    self.call_deferred("free")
    
    var game_over = load("res://demo/game_over.tscn").instance()
    game_over.winner_name = winner_player.display_name
    tree.root.add_child(game_over)