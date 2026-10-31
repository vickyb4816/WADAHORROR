extends CharacterBody3D
class_name TatyaHunter

enum State { PATROL, INVESTIGATE, CHASE, SEARCH, RETURN }

@export var patrol_points: Array[Node3D] = []
@export var walk_speed := 1.65
@export var chase_speed := 3.1
@export var sight_distance := 11.0
@export var hearing_distance := 5.0
@export var lose_target_after := 4.0

var state: State = State.PATROL
var player: Node3D
var patrol_index := 0
var last_known_position := Vector3.ZERO
var lost_sight_time := 0.0
var home_position := Vector3.ZERO

func _ready() -> void:
    home_position = global_position
    add_to_group("tatya")

func set_player(target: Node3D) -> void:
    player = target

func _physics_process(delta: float) -> void:
    if player == null or not is_instance_valid(player):
        return
    var distance := global_position.distance_to(player.global_position)
    var can_see := distance <= sight_distance and _has_line_of_sight()
    if can_see:
        last_known_position = player.global_position
        lost_sight_time = 0.0
        state = State.CHASE
    elif state == State.CHASE:
        lost_sight_time += delta
        if lost_sight_time >= lose_target_after:
            state = State.SEARCH
    match state:
        State.PATROL:
            _move_to_patrol_point(delta)
        State.CHASE:
            _move_towards(last_known_position, chase_speed, delta)
        State.SEARCH:
            _move_towards(last_known_position, walk_speed, delta)
            if global_position.distance_to(last_known_position) < 0.8:
                state = State.RETURN
        State.RETURN:
            _move_towards(home_position, walk_speed, delta)
            if global_position.distance_to(home_position) < 0.8:
                state = State.PATROL
        State.INVESTIGATE:
            _move_towards(last_known_position, walk_speed, delta)

func _has_line_of_sight() -> bool:
    var space := get_world_3d().direct_space_state
    var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP, player.global_position + Vector3.UP)
    query.exclude = [self]
    var hit := space.intersect_ray(query)
    return hit.is_empty() or hit.get("collider") == player

func _move_to_patrol_point(delta: float) -> void:
    if patrol_points.is_empty():
        return
    var target := patrol_points[patrol_index].global_position
    _move_towards(target, walk_speed, delta)
    if global_position.distance_to(target) < 0.7:
        patrol_index = (patrol_index + 1) % patrol_points.size()

func _move_towards(target: Vector3, speed: float, _delta: float) -> void:
    var flat := target - global_position
    flat.y = 0.0
    if flat.length() < 0.1:
        velocity.x = 0.0
        velocity.z = 0.0
    else:
        flat = flat.normalized()
        velocity.x = flat.x * speed
        velocity.z = flat.z * speed
        look_at(global_position + flat, Vector3.UP)
    if not is_on_floor():
        velocity += get_gravity() * get_physics_process_delta_time()
    move_and_slide()
