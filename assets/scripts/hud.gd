extends Control

onready var building_panel = $"camp_management"

onready var beer_label = $"right/beer"
onready var sausage_label = $"right/sausage"

func show_camp_hud():
    building_panel.show()

func hide_camp_hud():
    building_panel.hide()
	
func update_resources_panel(beer, sausage):
	beer_label.set_value(beer)
	sausage_label.set_value(sausage)
