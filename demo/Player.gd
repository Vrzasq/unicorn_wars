extends RigidBody2D


export(PackedScene) var BulletScene
export(NodePath) var bullet_container_path
export(NodePath) var other_player_node_path
export(Vector2) var shot_power

var other_player: RigidBody2D

func _ready() -> void:
    other_player = get_node(other_player_node_path) as RigidBody2D

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.is_action_pressed("shot"):
            shot_bullet()
    
    
func shot_bullet() -> void:
    var bullet: RigidBody2D = create_bullet()
    var bullet_container = get_node(bullet_container_path)
    bullet_container.add_child(bullet)
    bullet.apply_impulse(Vector2(0, -1), Vector2(shot_power.x, shot_power.y))
    print("shot")
    
    
    
func create_bullet() -> RigidBody2D:
    var bullet = BulletScene.instance() as RigidBody2D
    bullet.position = $ShootingPoint.global_position
    bullet.collision_layer = other_player.collision_layer
    bullet.collision_mask = other_player.collision_mask
    
    return bullet