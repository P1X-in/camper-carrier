extends Position3D

var navigation = preload("res://assets/scripts/bot_navigation.gd").new()

export var loot_sausage = 50
export var loot_beer = 25

var current_target = Vector2(0, 0)
var current_target_float = Vector2(0.0, 0.0)
var world

func select_random_start():
    var index = randi() % navigation.pairs.size()
    current_target = navigation.pairs[index][0]
    current_target_float = Vector2(float(current_target.x), float(current_target.y))
    print("Barrel spawning at (" + str(current_target.x) + "," + str(current_target.y) + ")")

func _init():
    select_random_start()

func _ready():
    world = get_parent()
    self.transform.origin = Vector3(current_target_float.x, world.BLUE_LINE * world.MAP_HEIGHT_FACTOR, current_target_float.y)

func hit_by_garbage():
    destroyed(0)

func hit_by_party():
    destroyed(0)

func destroyed(multiplier=1):
    world.barrel_counter -= 1
    world.spawned_barrels.erase(get_instance_id())
    world.player.add_resources(loot_sausage * multiplier, loot_beer * multiplier)
    queue_free()
