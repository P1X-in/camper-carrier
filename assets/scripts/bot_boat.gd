extends Position3D

var navigation = preload("res://assets/scripts/bot_navigation.gd").new()

export var rotate_speed = 2.0
export var move_speed = 0.4
export var hitbox_size = 3.0

const ANGLE_THRESHOLD = 0.1
const TARGET_PROXIMITY = 10.0

var current_target = Vector2(0, 0)
var previous_target = null
var current_target_float = Vector2(0.0, 0.0)
var world

var angle_y = 0
var _angle_y = 0
var move_to


func select_random_start():
    var index = randi() % navigation.pairs.size()
    current_target = navigation.pairs[index][0]
    current_target_float = Vector2(float(current_target.x), float(current_target.y))
    print("Bot spawning at (" + str(current_target.x) + "," + str(current_target.y) + ")")

func select_next_target():
    var possible_destinations = navigation.get_points(current_target, previous_target)
    previous_target = current_target

    var index = randi() % possible_destinations.size()
    current_target = possible_destinations[index]
    current_target_float = Vector2(float(current_target.x), float(current_target.y))

    print("Bot " + str(self.get_instance_id()) + " moving (" + str(previous_target.x) + "," + str(previous_target.y) + ") -> (" + str(current_target.x) + "," + str(current_target.y) + ")")

func _init():
    select_random_start()

func _ready():
    world = get_parent()
    self.transform.origin = Vector3(current_target_float.x, world.BLUE_LINE * world.MAP_HEIGHT_FACTOR, current_target_float.y)
    move_to = transform.origin
    select_next_target()

func _process(delta):
    if angle_y != _angle_y:
        _angle_y += (angle_y - _angle_y) * delta * 10.0

        var basis = Basis(Vector3(0.0, 1.0, 0.0), deg2rad(_angle_y))
        transform.basis = basis

    if move_to != transform.origin:
        var new_origin = transform.origin
        new_origin = transform.origin + (move_to - transform.origin) * delta * 10.0
        new_origin.y = transform.origin.y
        transform.origin = new_origin

func _physics_process(delta):
    var target_diff_vector = Vector2(transform.origin.x, transform.origin.z) - current_target_float
    var angle = rad2deg(target_diff_vector.angle())
    var angle_value = angle - angle_y

    if target_diff_vector.length() > TARGET_PROXIMITY:
        var front_back = transform.basis.z
        front_back.y = 0.0
        front_back = front_back.normalized()
        move_to -= front_back * move_speed
    else:
        move_to = transform.origin
        select_next_target()

    var move_to_diff_vector = Vector2(transform.origin.x, transform.origin.z) - Vector2(move_to.x, move_to.z)
    var move_to_angle = rad2deg(move_to_diff_vector.angle())
    angle_value = move_to_diff_vector.angle() - target_diff_vector.angle()

    if abs(angle_value) > ANGLE_THRESHOLD and move_to != transform.origin:
        if angle_value > 0:
            angle_y += rotate_speed
        else:
            angle_y -= rotate_speed

func hit_by_garbage():
    world.counter -= 1
    world.spawned_ships.erase(get_instance_id())
    queue_free()
