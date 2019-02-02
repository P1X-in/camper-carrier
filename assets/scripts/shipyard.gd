extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
    $menu/buttons/back.grab_focus()

func _input(event):
    if Input.is_key_pressed(KEY_ESCAPE):
        back_to_menu()
    if Input.is_action_pressed("game_b"):
        back_to_menu()
    if Input.is_action_pressed("game_a"):
        back_to_menu()

func back_to_menu():
    get_tree().change_scene("assets/scenes/menu.tscn")

func departure_ship():
    get_tree().change_scene("assets/scenes/game.tscn")
    
func _on_back_pressed():
    back_to_menu()

func _on_select_pressed():
    departure_ship()
    
    
