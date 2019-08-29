extends RigidBody2D

export(float) var time_to_destroy_on_hit = 5.0
export(float) var time_to_destroy = 15.0

var destroy_timer: Timer
var collided = false
var set_state = false

signal bullet_destroyed


func _ready() -> void:
    destroy_timer = $DestroyTimer
    destroy_timer.start(time_to_destroy)


func _on_RigidBody2D_body_entered(body: Node) -> void:
    if !collided:
        destroy_timer.start(time_to_destroy_on_hit)
        collided = true
        set_state = true
    

func _on_DestroyTimer_timeout() -> void:
    emit_signal("bullet_destroyed")
    self.queue_free()
        
    
func _physics_process(delta: float) -> void:
    rotate_based_on_valocity()
    

func rotate_based_on_valocity() -> void:
    if !collided:
        rotation = linear_velocity.angle()    