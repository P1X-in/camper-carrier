extends Spatial

export var MAP_SIZE = Vector2(1024, 1024)
export var MAP_HEIGHT_FACTOR = 128
export var GAME_MODE = 1
export var SHALLOWS_LINE = 0.39
export var BLUE_LINE = 0.4
export var GREEN_LINE = 0.5

onready var heightmap_file = preload("res://assets/materials/worldmap.png")
onready var units = [
    #preload('res://tscns/knight.tscn')
]

var height_map
var counter = 0

func _ready():
    height_map = heightmap_file.get_data()


func get_height(pos, below_water=false):
    var pos2 = convert_pos(pos)
    height_map.lock()
    var h = height_map.get_pixel(pos2.x, pos2.y).r
    height_map.unlock()
    if h < BLUE_LINE and not below_water: h = BLUE_LINE
    var terrain_h = h * MAP_HEIGHT_FACTOR
    #print(terrain_h)
    return terrain_h

func convert_pos(pos):
    return Vector2(int(MAP_SIZE.x*.5+pos.x), int(MAP_SIZE.y*.5+pos.z))

func spawn_unit(id, pos):
    var new_unit = units[id].instance()
    new_unit.translate(pos)
    $terrain.add_child(new_unit)
    counter += 1

func change_map_seed():
    pass

func _on_world_tick_timeout():
    pass