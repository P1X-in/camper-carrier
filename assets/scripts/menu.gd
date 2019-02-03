extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
    $box/buttons/departure.grab_focus()
    set_graphics_settings(ProjectSettings.get_setting("PERFORMANCE"))
    
func _input(event):
    if Input.is_key_pressed(KEY_ESCAPE):
        $audio/click.play()
        back_to_intro()
    if Input.is_action_pressed("game_b"):
        $audio/click.play()
        back_to_intro()
        
func departure_ship():
    get_tree().change_scene("assets/scenes/game.tscn")
    
func enter_shipyard():
    get_tree().change_scene("assets/scenes/shipyard.tscn")
   
func back_to_intro():
    get_tree().change_scene("assets/scenes/intro.tscn")
   
func _on_departure_pressed():
    $audio/click.play()
    departure_ship()

func _on_shipyard_pressed():
    $audio/click.play()
    enter_shipyard()
 
func _on_back_pressed():
    $audio/click.play()
    back_to_intro()


func set_graphics_settings(gfx_type):
    if gfx_type == "PERF_HI":
        $"world/sun".shadow_enabled = true
        ProjectSettings.set_setting("rendering/quality/directional_shadow/size", 8192)
        ProjectSettings.set_setting("rendering/quality/reflections/high_quality_ggx", true)
        ProjectSettings.set_setting("rendering/quality/voxel_cone_tracing/high_quality", true)
        ProjectSettings.set_setting("rendering/quality/shading/force_vertex_shading", false)
        get_viewport().msaa = Viewport.MSAA_4X
        ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 2)
        $"world/environment".environment.dof_blur_far_enabled = true
        $"world/environment".environment.dof_blur_far_distance = 512
        $"world/environment".environment.dof_blur_far_transition = 8
        $"world/environment".environment.dof_blur_far_amount = 0.1
        $"world/environment".environment.dof_blur_far_quality = Environment.DOF_BLUR_QUALITY_MEDIUM
        $"world/environment".environment.ss_reflections_max_steps = 256
        $"world/environment".environment.glow_enabled = true
        $"world/environment".environment.glow_bloom = 0.3
 
    if gfx_type == "PERF_NORMAL":
        $"world/sun".shadow_enabled = true
        ProjectSettings.set_setting("rendering/quality/directional_shadow/size", 4096)
        ProjectSettings.set_setting("rendering/quality/reflections/high_quality_ggx", false)
        ProjectSettings.set_setting("rendering/quality/voxel_cone_tracing/high_quality", false)
        ProjectSettings.set_setting("rendering/quality/shading/force_vertex_shading", false)
        get_viewport().msaa = Viewport.MSAA_DISABLED
        ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 1)
        $"world/environment".environment.dof_blur_far_enabled = false
        $"world/environment".environment.ss_reflections_max_steps = 128
        $"world/environment".environment.glow_enabled = false
        
    if gfx_type == "PERF_LOW":
        $"world/sun".shadow_enabled = false
        ProjectSettings.set_setting("rendering/quality/directional_shadow/size", 2048)
        ProjectSettings.set_setting("rendering/quality/reflections/high_quality_ggx", false)
        ProjectSettings.set_setting("rendering/quality/voxel_cone_tracing/high_quality", false)
        ProjectSettings.set_setting("rendering/quality/shading/force_vertex_shading", true)
        get_viewport().msaa = Viewport.MSAA_DISABLED
        ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 0)
        $"world/environment".environment.dof_blur_far_enabled = false
        $"world/environment".environment.ss_reflections_max_steps = 64
        $"world/environment".environment.glow_enabled = false
