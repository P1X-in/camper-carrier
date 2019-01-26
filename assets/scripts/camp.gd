extends MeshInstance

var player

var tiles = []
var cursor = Vector2(0, 0)

func _ready():
    player = get_parent().get_parent()

    for i in range(0, 3):
        tiles.append([null, null, null, null, null])
