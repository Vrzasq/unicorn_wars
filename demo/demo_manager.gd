extends Node2D

class_name DemoManager

var players = {}
var current_player : Player
var player_name_display : RainbowLabel

func _ready() -> void:
    player_name_display = $HUD/PlayerName
    assign_players()
    choose_statring_player()
    print(current_player.name)


func assign_players() -> void:
    var all_players := get_tree().get_nodes_in_group("players")
    for player in all_players:
        players[player.name] = player
        player.connect("turn_end", self, "on_player_turn_end")
            

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
    print(other_player.name)
    current_player.end_turn()
    current_player.reset_position()
    other_player.start_turn()
    other_player.reset_position()
    current_player = other_player
    set_current_player_name()
    
    
func set_current_player_name() -> void:
    player_name_display.set_player_name(current_player.name)