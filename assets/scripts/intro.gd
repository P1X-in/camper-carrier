extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
    $menu/buttons/low.grab_focus()

func _input(event):
    if Input.is_key_pressed(KEY_ESCAPE):
        quit_game()

func _on_low_pressed():
    ProjectSettings.set_setting("PERFORMANCE", "PERF_LOW")
    start_game()
    
func _on_medium_pressed():
    ProjectSettings.set_setting("PERFORMANCE", "PERF_MEDIUM")
    start_game()

func _on_hi_pressed():
    ProjectSettings.set_setting("PERFORMANCE", "PERF_HI")
    start_game()

func start_game():
    get_tree().change_scene("assets/scenes/menu.tscn")

func _on_exit_pressed():
    quit_game()
    
func quit_game():
    get_tree().quit()