extends RigidBody2D

export(float) var time_to_destroy_on_hit = 5.0
export(float) var time_to_destroy = 15.0

var destroy_timer: Timer
var collided := false


func _ready() -> void:
    print("ready")
    destroy_timer = $DestroyTimer
    destroy_timer.start(time_to_destroy)


func _on_RigidBody2D_body_entered(body: Node) -> void:
    if !collided:
        destroy_timer.start(time_to_destroy_on_hit)
        collided = true
    

func _on_DestroyTimer_timeout() -> void:
    self.queue_free()