extends Control

onready var title_node = $"corner/message_box/title"
onready var description_node = $"corner/message_box/message"
onready var button_node = $"corner/message_box/title"
onready var sausage_node = $"corner/message_box/title"
onready var beer_node = $"corner/message_box/title"


func show_building_card(tile):
    var level = tile.get_basic()

    var title = "Build " + level.building_name
    var description = level.description
    var button_icon = 1
    var button_label = "Build"
    var sausage = level.cost_sausage
    var beer = level.cost_beer

    self._fill_card(title, description, button_icon, button_label, sausage, beer)

func show_upgrade_card(tile, current_level):
    var level = tile.get_upgrade(current_level)

    var title
    var description
    var button_icon
    var button_label
    var sausage
    var beer

    if level != null:
        title = "Upgrade to " + level.building_name
        description = level.description
        button_icon = 0
        button_label = "Upgrade"
        sausage = level.cost_sausage
        beer = level.cost_beer
    else:
        level = tile.get_level(current_level)
        title = "Building fully upgraded "
        description = level.description
        button_icon = null
        button_label = null
        sausage = null
        beer = null

    self._fill_card(title, description, button_icon, button_label, sausage, beer)

func _fill_card(title, description, button_icon, button_label, sausage, beer):
    return