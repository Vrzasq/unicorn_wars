extends Node2D

class_name ShotIndicator

export(int) var rotation_amount = 5
export(bool) var is_running = true

var line : Line2D


func _ready() -> void:
    line = $Line2D


func _process(delta: float) -> void:
    if is_running:
        line.rotation_degrees += delta * rotation_amount
    
    if line.rotation_degrees >= 90 || line.rotation_degrees <= -90:
        rotation_amount *= -1


func start() -> void:
    is_running = true
    
    
func stop() -> void:
    is_running = false


func get_direction() -> Vector2:
    var direction = Vector2(sin(line.rotation), cos(line.rotation))
    
    if direction.x < -1:
        direction.x = -1

    if direction.y < 0:
        direction.y = 0

    return direction