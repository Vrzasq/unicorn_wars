extends RigidBody2D


export(PackedScene) var PowerIndicatorScene
export(NodePath) var power_indicator_placeholder_path
export(PackedScene) var BulletScene
export(NodePath) var bullet_container_path
export(NodePath) var other_player_node_path
export(int) var max_shot_power
export(NodePath) var starting_position_path
export(NodePath) var shot_indicator_path
export(NodePath) var hud_path

var other_player: RigidBody2D
var starting_position: Node2D
var reset_state := false
var shot_indicator : ShotIndicator
var hud : Node
var power_indicator_placeholder : Node2D
var power_indicator : PowerIndicator

func _ready() -> void:
    shot_indicator = get_node(shot_indicator_path)
    other_player = get_node(other_player_node_path) as RigidBody2D
    starting_position = get_node(starting_position_path) as Node2D
    starting_position.transform = transform
    hud = get_node(hud_path)
    power_indicator_placeholder = get_node(power_indicator_placeholder_path)
    


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.is_action_pressed("shot"):
            shot_indicator.stop()
            display_power_indicator()
            
        if event.is_action_released("shot"):
            shot_bullet()
            hide_power_indicator()
            shot_indicator.start()
    
    if event.is_action_pressed("ui_accept"):
        reset_state = true

    
func shot_bullet() -> void:
    var bullet: RigidBody2D = create_bullet()
    var bullet_container = get_node(bullet_container_path)
    bullet_container.add_child(bullet)
    var power = max_shot_power * power_indicator.get_power_ratio()
    bullet.apply_central_impulse(Vector2(power, -power) * shot_indicator.get_direction())
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
    
    
func display_power_indicator() -> void:
    power_indicator = PowerIndicatorScene.instance() as Node2D
    power_indicator.position = power_indicator_placeholder.position
    hud.add_child(power_indicator)
    
    
func hide_power_indicator() -> void:
    power_indicator.queue_free()