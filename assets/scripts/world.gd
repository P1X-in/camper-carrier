extends Spatial

export var MAP_SIZE = Vector2(1024, 1024)
export var MAP_HEIGHT_FACTOR = 128
export var GAME_MODE = 1
export var BLUE_LINE = 0.4
export var GREEN_LINE = 0.5

onready var heightmap_file = preload("res://assets/materials/heightmap.tres")
onready var units = [
	#preload('res://tscns/knight.tscn')
]

var height_map
var counter = 0

func _ready():
	var noise = heightmap_file.get_noise()
	height_map = noise.get_image(MAP_SIZE[0], MAP_SIZE[1])
	
	
func get_height(pos):
	var pos2 = convert_pos(pos)
	height_map.lock()
	var h = height_map.get_pixel(pos2.x, pos2.y).r
	height_map.unlock()
	if h < BLUE_LINE: h = BLUE_LINE
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
	heightmap_file.get_noise().set_seed(randi()*1024)
	height_map = heightmap_file.get_noise().get_image(MAP_SIZE[0], MAP_SIZE[1])

func _on_world_tick_timeout():
	pass