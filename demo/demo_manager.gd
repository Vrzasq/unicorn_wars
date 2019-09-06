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
    print(current_player.display_name)
    get_tree().paused = true


func assign_players() -> void:
    var all_players := get_tree().get_nodes_in_group("players")
    
    for player in all_players:
        players[player.name] = player
        player.connect("turn_end", self, "on_player_turn_end")
        
    if player1_name != "":
        players.Player1.display_name = player1_name
        
    if player2_name != "":
        players.Player2.display_name = player2_name
        
            

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
    player_name_display.set_text(current_player.display_name)


func _on_GameStartTimer_timeout() -> void:
    get_tree().paused = false
    $GameStartTimer.queue_free()
