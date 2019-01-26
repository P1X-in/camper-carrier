extends Position3D

var navigation = preload("res://assets/scripts/bot_navigation.gd").new()

var current_target = Vector2(0, 0)
var world

func select_random_start():
    var index = randi() % navigation.pairs.size()
    var target = navigation.pairs[index][0]
    current_target = Vector2(float(target.x), float(target.y))

func select_next_target():
    return

func _init():
    select_random_start()

func _ready():
    world = get_parent()
    self.transform.origin = Vector3(current_target.x, world.BLUE_LINE * world.MAP_HEIGHT_FACTOR, current_target.y)

func _process(delta):
    #if angle_x != _angle_x or angle_y != _angle_y:
    #    _angle_x += (angle_x - _angle_x) * delta * 10.0
    #    _angle_y += (angle_y - _angle_y) * delta * 10.0
    #
    #    var basis = Basis(Vector3(0.0, 1.0, 0.0), deg2rad(_angle_y))
    #    basis *= Basis(Vector3(1.0, 0.0, 0.0), deg2rad(_angle_x))
    #    transform.basis = basis
    #
    #if move_to != transform.origin:
    #    var new_origin = transform.origin
    #    move_to.y = 0.0
    #    new_origin = transform.origin + (move_to - transform.origin) * delta * 10.0
    #    if world.get_height(new_origin, true) > world.SHALLOWS_LINE * world.MAP_HEIGHT_FACTOR:
    #        new_origin = transform.origin
    #        move_to = new_origin
    #
    #    new_origin.y = transform.origin.y
    #    transform.origin = new_origin
    return

