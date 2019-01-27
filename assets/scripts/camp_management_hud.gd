extends Control

onready var title_node = $"corner/message_box/title"
onready var description_node = $"corner/message_box/message"
onready var button_node = $"corner/message_box/b"
onready var sausage_node = $"corner/message_box/sausage"
onready var beer_node = $"corner/message_box/beer"
onready var action_node = $"corner/message_box/b"

onready var player_node = $"../../player"

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
    title_node.set_text(title)
    description_node.set_text(description)
    if button_icon != null:
        button_node.show()
        button_node.set_frame(button_icon)
    else:
        button_node.hide()

    if button_label != null:
        button_node.get_node('label').show()
        button_node.get_node('label').set_text(button_label)
    else:
        button_node.get_node('label').hide()

    if sausage != null:
        sausage_node.show()
        sausage_node.get_node('label').set_text(str(sausage))
    else:
        sausage_node.hide()

    if beer != null:
        beer_node.show()
        beer_node.get_node('label').set_text(str(beer))
    else:
        beer_node.hide()
        
    if is_possible(sausage, beer):
        action_node.show()
    else:
        action_node.hide()
        
func node_color(node, sausage, beer):
    if player_node.check_resources(sausage, beer):
        node.get_node('label').add_color_override("font_color", Color(1,1,1))
    else:
        node.get_node('label').add_color_override("font_color", Color(1,0,0))
        
func is_possible(sausage, beer):
    return sausage != null and beer != null and player_node.check_resources(sausage, beer)
