extends Node2D

class_name ShotIndicator

export(float) var playback_speed = 1.75

var line : Line2D
var animation_player : AnimationPlayer


func _ready() -> void:
    line = $Line2D as Line2D
    animation_player = $Line2D/AnimationPlayer as AnimationPlayer
    animation_player.playback_speed = playback_speed


func start() -> void:
    animation_player.play()
    
    
func stop() -> void:
    animation_player.stop(false)


func get_direction() -> Vector2:
    var direction = Vector2(sin(line.rotation), cos(line.rotation))
    
    if direction.x < -1:
        direction.x = -1

    if direction.y < 0:
        direction.y = 0

    return direction