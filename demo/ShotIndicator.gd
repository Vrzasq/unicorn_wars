extends Node2D

class_name ShotIndicator

export(int) var line_length = 100
export(int) var rotation_amount = 5
var line : Line2D


func _ready() -> void:
    line = $Line2D


func _process(delta: float) -> void:
    line.rotation_degrees += delta * rotation_amount
    
    if line.rotation_degrees >= 90:
        rotation_amount *= -1

    if line.rotation_degrees <= -90:
        rotation_amount *= -1
        

func get_direction() -> Vector2:
    var direction = Vector2(sin(line.rotation), cos(line.rotation))
    
    if direction.x < -1:
        direction.x = -1

    if direction.y < 0:
        direction.y = 0

    print(direction)
    return direction