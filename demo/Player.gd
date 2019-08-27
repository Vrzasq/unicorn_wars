extends RigidBody2D


export(PackedScene) var BulletScene
export(NodePath) var bullet_container_path
export(NodePath) var other_player_node_path
export(int) var shot_power
export(NodePath) var starting_position_path
export(NodePath) var shot_indicator_path

var other_player: RigidBody2D
var starting_position: Node2D
var reset_state := false
var shot_indicator : ShotIndicator

func _ready() -> void:
    shot_indicator = get_node(shot_indicator_path)
    other_player = get_node(other_player_node_path) as RigidBody2D
    starting_position = get_node(starting_position_path) as Node2D
    starting_position.transform = transform


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.is_action_pressed("shot"):
            shot_bullet()
    
    if event.is_action_pressed("ui_accept"):
        reset_state = true

    
func shot_bullet() -> void:
    var bullet: RigidBody2D = create_bullet()
    var bullet_container = get_node(bullet_container_path)
    bullet_container.add_child(bullet)
    bullet.apply_central_impulse(Vector2(shot_power, -shot_power) * shot_indicator.get_direction())
    print("shot")
    
    
func create_bullet() -> RigidBody2D:
    var bullet = BulletScene.instance() as RigidBody2D
    bullet.position = $ShootingPoint.global_position
    bullet.collision_layer = other_player.collision_layer
    bullet.collision_mask = other_player.collision_mask
    
    return bullet
    
    
func _integrate_forces(state: Physics2DDirectBodyState) -> void:
    if reset_state:
        reset_state(state)
        reset_state = false
        
        
func reset_state(state: Physics2DDirectBodyState) -> void:
    state.transform = starting_position.transform
    state.linear_velocity = Vector2.ZERO
    state.angular_velocity = 0.0