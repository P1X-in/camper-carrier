extends Control

onready var camp_hud = $"camp_management"

onready var beer_label = $"right/beer/label"
onready var sausage_label = $"right/sausage/label"

func show_camp_hud():
    camp_hud.show()

func hide_camp_hud():
    camp_hud.hide()

func update_resources_panel(beer, sausage):
	beer_label.set_value(beer)
	sausage_label.set_value(sausage)
