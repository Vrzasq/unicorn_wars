extends RigidBody2D

class_name Player

signal turn_end
signal damage_taken

export(PackedScene) var PowerIndicatorScene
export(NodePath) var power_indicator_placeholder_path
export(PackedScene) var BulletScene
export(NodePath) var bullet_container_path
export(NodePath) var other_player_node_path
export(int) var max_shot_power
export(NodePath) var starting_position_path
export(NodePath) var shot_indicator_path
export(NodePath) var hud_path
export(int) var player_hp = 150
export(int) var armor = 100

var other_player: RigidBody2D
var starting_position: Node2D
var reset_state := false
var shot_indicator : ShotIndicator
var hud : Node
var power_indicator_placeholder : Node2D
var power_indicator : PowerIndicator
var shooting_star : Particles2D
var this_player_turn = false
var can_shoot = false


func _ready() -> void:
    shot_indicator = get_node(shot_indicator_path)
    other_player = get_node(other_player_node_path) as RigidBody2D
    starting_position = get_node(starting_position_path) as Node2D
    starting_position.transform = transform
    hud = get_node(hud_path)
    power_indicator_placeholder = get_node(power_indicator_placeholder_path)
    shooting_star = hud.get_node("ShootingStars")
    

func _input(event: InputEvent) -> void:
    if this_player_turn && can_shoot:
        handle_player_input(event)


func handle_player_input(event : InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.is_action_pressed("shot"):
            shot_indicator.stop()
            emit_starts()
            display_power_indicator()
            
        if event.is_action_released("shot"):
            shot_bullet()
            hide_power_indicator()
            stop_starts()
            shot_indicator.start()
    
    if event.is_action_pressed("ui_accept"):
        reset_state = true

    
func shot_bullet() -> void:
    var bullet: RigidBody2D = create_bullet()
    var bullet_container = get_node(bullet_container_path)
    bullet_container.add_child(bullet)
    var power = max_shot_power * power_indicator.get_power_ratio()
    bullet.apply_central_impulse(Vector2(power, -power) * shot_indicator.get_direction())
    can_shoot = false
    print("shot")
    
    
func create_bullet() -> RigidBody2D:
    var bullet = BulletScene.instance() as RigidBody2D
    bullet.position = $ShootingPoint.global_position
    bullet.collision_layer = other_player.collision_layer
    bullet.collision_mask = other_player.collision_mask
    bullet.connect("bullet_destroyed", self, "_on_bullet_destroyed")
    
    return bullet
    
    
func _integrate_forces(state: Physics2DDirectBodyState) -> void:
    if reset_state:
        _reset_state(state)
        reset_state = false
        
        
func _reset_state(state: Physics2DDirectBodyState) -> void:
    state.transform = starting_position.transform
    state.linear_velocity = Vector2.ZERO
    state.angular_velocity = 0.0


func reset_position() -> void:
    reset_state = true
    
    
func display_power_indicator() -> void:
    power_indicator = PowerIndicatorScene.instance() as Node2D
    power_indicator.position = power_indicator_placeholder.position
    hud.add_child(power_indicator)
    
    
func hide_power_indicator() -> void:
    power_indicator.queue_free()
    

func emit_starts() -> void:
    shooting_star.position = $ShootingPoint.global_position
    shooting_star.emitting = true


func stop_starts() -> void:
    shooting_star.emitting = false
    
    
func end_turn() -> void:
    this_player_turn = false
    
    
func start_turn() -> void:
    this_player_turn = true
    can_shoot = true
    

func _on_bullet_destroyed() -> void:
    emit_signal("turn_end", other_player as Player)
    pass

func _on_Player_body_entered(body: Node) -> void:
    var bullet = body as Bullet
    if bullet && body.can_damage:
        bullet.can_damage = false
        var damage := calculate_damage(bullet.get_bullet_damage(), bullet.min_damage)
        take_damage(damage)
        
        
func take_damage(damage : int) -> void:
    var damage_taken_arg := DamageTakenArgs.new()
    damage_taken_arg.current_hp = player_hp
    damage_taken_arg.damage = damage
    player_hp -= damage
    damage_taken_arg.target_hp = player_hp
    emit_signal("damage_taken", damage_taken_arg)
    print(player_hp)


func calculate_damage(bullet_damage : int, min_damage : int) -> int:
    var damage = int((((bullet_damage / mass) * 0.1) - armor) * 0.3 + min_damage)
    
    if damage < min_damage:
        damage = min_damage

    return damage