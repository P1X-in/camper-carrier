extends MeshInstance

const STEP_THRESHOLD = 0.5

var player

var tiles = []
var tiles_flat = []
var grid_size = Vector2(4, 2)
var cursor = Vector2(0, 0)
var axis_value = Vector2(0, 0)
var need_reset = false

func _ready():
    player = get_parent().get_parent()

    for i in range(0, 3):
        tiles.append([null, null, null, null, null])


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

