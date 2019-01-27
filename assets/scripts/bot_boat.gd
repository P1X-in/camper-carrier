extends Position3D

var navigation = preload("res://assets/scripts/bot_navigation.gd").new()

export var rotate_speed = 2.0
export var move_speed = 0.4
export var hitbox_size = 3.0
export var aggro_range = 100.0
export var barrage_size = 2
export var barrage_cooldown = 2
export var hp = 3
export var loot_sausage = 10
export var loot_beer = 5

const ANGLE_THRESHOLD = 0.1
const TARGET_PROXIMITY = 10.0
const BARRAGE_DELAY = 0.1

var current_target = Vector2(0, 0)
var previous_target = null
var current_target_float = Vector2(0.0, 0.0)
var world

var angle_y = 0
var _angle_y = 0
var move_to

var current_hp
var projectile_template = preload("res://assets/scenes/projectile.tscn")
var shot_timer = 2
var barrage_progress = 0
var barrage_timer = 1

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
    current_hp = hp

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

    var player_direction = Vector2(world.player.transform.origin.x, world.player.transform.origin.z) - Vector2(self.transform.origin.x, self.transform.origin.z)
    shot_timer += delta
    barrage_timer += delta
    if player_direction.length() < aggro_range and shot_timer > barrage_cooldown and barrage_progress < barrage_size and barrage_timer > BARRAGE_DELAY:
        shoot()
        barrage_progress += 1
        barrage_timer = 0.0
        if barrage_progress == barrage_size:
            shot_timer = 0.0
            barrage_progress = 0

func hit_by_garbage():
    current_hp -= 1
    $hit.emitting = true
    if current_hp == 0:
        destroyed()

func destroyed():
    world.counter -= 1
    world.spawned_ships.erase(get_instance_id())
    world.player.add_resources(loot_sausage, loot_beer)
    queue_free()

func shoot():
    var direction = Vector2(world.player.transform.origin.x, world.player.transform.origin.z) - Vector2(self.transform.origin.x, self.transform.origin.z)
    var elevation = 1

    direction = direction.normalized()

    var new_garbage = projectile_template.instance()
    new_garbage.direction = Vector3(direction.x, 0.0, direction.y)
    new_garbage.hostile = true
    new_garbage.transform.origin = Vector3(self.transform.origin.x, self.transform.origin.y + elevation, self.transform.origin.z)
    world.add_child(new_garbage)
