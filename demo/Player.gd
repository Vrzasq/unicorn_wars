extends RigidBody2D

class_name Player

signal turn_end
signal damage_taken
signal died

const ShootingStarsScene = preload("res://scenes/player/shooting_stars.tscn")
const DeathBlowScene = preload("res://scenes/player/death_blow.tscn")
var bouncy_material = preload("res://bouncy_material.tres")

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
export(String) var display_name = "Player"
export(bool) var can_be_dmg_after_hit = false
export(int) var death_power = 8000
export(int) var game_over_timeout = 10

var other_player: RigidBody2D
var starting_position: Node2D
var reset_state := false
var shot_indicator : ShotIndicator
var hud : Node
var power_indicator_placeholder : Node2D
var power_indicator : PowerIndicator
var shooting_stars : Particles2D
var this_player_turn = false
var can_shoot = false
var dead = false


func _ready() -> void:
    shot_indicator = get_node(shot_indicator_path)
    other_player = get_node(other_player_node_path) as RigidBody2D
    starting_position = get_node(starting_position_path) as Node2D
    starting_position.transform = transform
    hud = get_node(hud_path)
    power_indicator_placeholder = get_node(power_indicator_placeholder_path)
    shooting_stars = ShootingStarsScene.instance()
    shooting_stars.position = $ShootingPoint.position
    add_child(shooting_stars)
    
    if display_name == "":
        display_name = name
    

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
    # print("shot")
    
    
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
    shooting_stars.emitting = true


func stop_starts() -> void:
    shooting_stars.emitting = false
    
    
func end_turn() -> void:
    this_player_turn = false
    
    
func start_turn() -> void:
    this_player_turn = true
    can_shoot = true
    

func _on_bullet_destroyed() -> void:
    if !other_player.dead:
        emit_signal("turn_end", other_player as Player)
    

func _on_Player_body_entered(body: Node) -> void:
    var bullet = body as Bullet
    if bullet && body.can_damage:
        bullet.can_damage = can_be_dmg_after_hit
        var damage := calculate_damage(bullet.get_bullet_damage(), bullet.min_damage)
        take_damage(damage)
        if dead:
            handle_death(bullet)
        
        
func take_damage(damage : int) -> void:
    var damage_taken_arg := DamageTakenArgs.new()
    damage_taken_arg.current_hp = player_hp
    damage_taken_arg.damage = damage
    reduce_hp(damage)
    damage_taken_arg.target_hp = player_hp
    emit_signal("damage_taken", damage_taken_arg)
    # print(player_hp)


func calculate_damage(bullet_damage : int, min_damage : int) -> int:
    var damage = int((((bullet_damage / mass) * 0.1) - armor) * 0.3 + min_damage)
    
    if damage < min_damage:
        damage = min_damage

    return damage
    
    
func reduce_hp(damage : int) -> void:
    player_hp -= damage
    if player_hp <= 0:
        player_hp = 0
        dead = true
        
func handle_death(bullet : Bullet) -> void:
    play_death_particles()
    apply_death_power(bullet)
    start_game_over_countdown()
    shot_indicator.queue_free()
    
    
func play_death_particles() -> void:
    var dead_blow = DeathBlowScene.instance()
    dead_blow.emitting = true
    dead_blow.position = Vector2.ZERO
    self.add_child(dead_blow)


func apply_death_power(bullet : Bullet) -> void:
    var direction = bullet.global_position.direction_to(self.global_position)
    self.physics_material_override = bouncy_material
    apply_central_impulse(direction * Vector2(death_power, -death_power))
    

func start_game_over_countdown() -> void:
    var game_over_timer = Timer.new()
    game_over_timer.start(game_over_timeout)
    game_over_timer.connect("timeout", self, "on_game_over_timeout")
    add_child(game_over_timer)
    
    
func on_game_over_timeout() -> void:
    emit_signal("died", other_player)