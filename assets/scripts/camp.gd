extends MeshInstance

const STEP_THRESHOLD = 0.5

const X_START = -1.794
const Y_START = -0.905
const Z_POS = 0.14
const X_DIFF = 0.922
const Y_DIFF = 0.895

var player

var tiles = []
var levels = []
var grid_size = Vector2(4, 2)
var cursor = Vector2(2, 1)
onready var cursor_node = $"cursor"
var axis_value = Vector2(0, 0)
var need_reset = false

var current_cost = null
onready var player_node = $"../../../player"

var buildings = {
    "bin" : preload("res://assets/scenes/tiles/tile_bin.tscn"),
    "camp" : preload("res://assets/scenes/tiles/tile_camp.tscn"),
    "fireplace" : preload("res://assets/scenes/tiles/tile_fireplace.tscn"),
    "beer" : preload("res://assets/scenes/tiles/tile_beer.tscn"),
    "music" : preload("res://assets/scenes/tiles/tile_music.tscn"),
    "toilet" : preload("res://assets/scenes/tiles/tile_toilet.tscn"),
}

var selected_building_template = 1
var selected_building_name = "camp"

var building_ghost = null


func _ready():
    player = get_parent().get_parent()

    for i in range(0, 3):
        tiles.append([null, null, null, null, null])
        levels.append([0, 0, 0, 0, 0])

    update_cursor_position()
    _add_tile('bin', Vector2(2, 1))
    _add_tile('camp', Vector2(0, 1))
    _add_tile('camp', Vector2(4, 2))


func _physics_process(delta):
    axis_value.x = Input.get_joy_axis(0, JOY_ANALOG_LX)
    axis_value.y = Input.get_joy_axis(0, JOY_ANALOG_LY)

    if player.active_camera != 3:
        return

    if abs(axis_value.x) < STEP_THRESHOLD and abs(axis_value.y) < STEP_THRESHOLD:
        need_reset = false

    if abs(axis_value.x) > STEP_THRESHOLD and not need_reset:
        need_reset = true
        if axis_value.x > 0:
            cursor.x += 1
            if cursor.x > grid_size.x:
                cursor.x = grid_size.x
        else:
            cursor.x -= 1
            if cursor.x < 0:
                cursor.x = 0
        update_cursor_position()

    if abs(axis_value.y) > STEP_THRESHOLD and not need_reset:
        need_reset = true
        if axis_value.y > 0:
            cursor.y += 1
            if cursor.y > grid_size.y:
                cursor.y = grid_size.y
        else:
            cursor.y -= 1
            if cursor.y < 0:
                cursor.y = 0
        update_cursor_position()

func update_cursor_position():
    var position = Vector3(X_START + cursor.x * X_DIFF, 0.341, Y_START + cursor.y * Y_DIFF)
    cursor_node.transform.origin = position

    add_ghost()

func clear_ghost():
    if building_ghost != null:
        building_ghost.queue_free()
        building_ghost = null

func add_ghost():
    clear_ghost()
    if tiles[cursor.y][cursor.x] == null:
        building_ghost = buildings[selected_building_name].instance()
        var new_position = Vector3(X_START + cursor.x * X_DIFF, Z_POS, Y_START + cursor.y * Y_DIFF)
        self.add_child(building_ghost)
        building_ghost.transform.origin = new_position
        building_ghost.transform.basis = building_ghost.transform.basis.scaled(Vector3(0.5, 0.5, 0.5))

        if player.hud != null and player.hud.camp_hud != null:
            player.hud.camp_hud.show_building_card(building_ghost)
    else:
        player.hud.camp_hud.show_upgrade_card(tiles[cursor.y][cursor.x], levels[cursor.y][cursor.x])

func _input(event):
    if player.active_camera == 3:
        if Input.is_action_pressed("game_x"):
            select_x()
        if Input.is_action_pressed("game_y"):
            select_y()
        if Input.is_action_pressed("shoulder_left"):
            _next_template()
        if Input.is_action_pressed("shoulder_right"):
            _prev_template()

func select_x():
    if tiles[cursor.y][cursor.x] == null:
        return
        
    _upgrade(cursor)

func select_y():
    if tiles[cursor.y][cursor.x] != null:
        return
    _add_tile(selected_building_name, cursor)

func _add_tile(name, position):
    clear_ghost()
    var new_tile = buildings[name].instance()
    
    # TODO - clean this part
    var level = new_tile.get_basic()
    var sausage = level.cost_sausage
    var beer = level.cost_beer
    
    if not player_node.check_resources(level.cost_sausage, level.cost_beer):
        return;
    else:
        player_node.take_resources(level.cost_sausage, level.cost_beer)
        
    var new_position = Vector3(X_START + position.x * X_DIFF, Z_POS, Y_START + position.y * Y_DIFF)
    self.add_child(new_tile)
    new_tile.transform.origin = new_position

    tiles[position.y][position.x] = new_tile
    levels[position.y][position.x] = 1

    new_tile.get_level(1).show()
    new_tile.get_level(2).hide()
    new_tile.get_level(3).hide()

    if player.hud != null and player.hud.camp_hud != null:
        player.hud.camp_hud.show_upgrade_card(new_tile, 1)

func _upgrade(position):
    var old_level = levels[position.y][position.x]
    var new_level = old_level + 1

    if new_level > 3:
        return

    var tile = tiles[position.y][position.x]
    
    var tile_level = tile.get_level(new_level)
    if not player_node.check_resources(tile_level.cost_sausage, tile_level.cost_beer):
        return;
    else:
        player_node.take_resources(tile_level.cost_sausage, tile_level.cost_beer)
        
    tile.get_node("level" + str(old_level)).hide()
    tile.get_node("level" + str(new_level)).show()
    levels[position.y][position.x] = new_level
    player.hud.camp_hud.show_upgrade_card(tile, new_level)

func _next_template():
    var names = buildings.keys()

    selected_building_template += 1

    if selected_building_template >= names.size():
        selected_building_template = 0

    selected_building_name = names[selected_building_template]
    add_ghost()


func _prev_template():
    var names = buildings.keys()

    selected_building_template -= 1

    if selected_building_template < 0:
        selected_building_template = names.size() - 1

    selected_building_name = names[selected_building_template]
    add_ghost()
