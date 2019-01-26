extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if Input.is_action_pressed("ui_accept"):
		get_tree().change_scene("assets/scenes/game.tscn")
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()