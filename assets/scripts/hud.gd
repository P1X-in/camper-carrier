extends Control

onready var building_panel = $"camp_management"


func show_camp_hud():
    building_panel.show()

func hide_camp_hud():
    building_panel.hide()

