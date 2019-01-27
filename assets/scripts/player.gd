extends Position3D

export var rotate_speed = 0.5
export var move_speed = 1.0
export var move_speed_lr = 0.5
export var move_speed_fb = 0.5
export var reverse_speed_multiplier = 0.4
export var hitbox_size = 3.0

var active_camera = 0
onready var cameras = [
    $"pivot/camera_drone",
    $"pivot/camera_spyglass",
    $"carrier/camera_onboard",
    $"carrier/camp/camera_camp",
    $"camera_satellite"
]
onready var pivot_point = $"pivot"
onready var camp = $"carrier/camp"
onready var hud = $"../HUD"

var projectile_template
var timer

const DEADZONE = 0.15

var angle_y = 0
var _angle_y = 0

var move_to
var world
var w = 0

var axis_value = Vector2()

var garbage_recharge = 1
var garbage_charges = 0
var garbage_stagger = 0.1
var garbage_stagger_timer = 2.0

var hp = 4
var current_hp = 4

var smokescreen_enabled = false
var smokescreen = false
var smokescreen_recharge = 300
var smokescreen_recharge_min = 10
var smokescreen_cost = 100
var smokescreen_cost_min = 10
var smokescreen_effect = false
var smokescreen_duration = 3

var noisemaker_enabled = false
var noisemaker = false
var noisemaker_recharge = 300
var noisemaker_recharge_min = 10
var noisemaker_cost = 80
var noisemaker_cost_min = 5
var noisemaker_range = 50
var noisemaker_duration = 5

var boarding_party_enabled = false
var boarding_party = false
var boarding_party_recharge = 120
var boarding_party_recharge_min = 10
var boarding_party_cost = 50
var boarding_party_cost_min = 0
var boarding_party_template

var sausage = 300
var beer = 200

func _ready():
    move_to = transform.origin
    world = get_parent()
    projectile_template = preload("res://assets/scenes/projectile.tscn")
    boarding_party_template = preload("res://assets/scenes/boarding_party.tscn")
    timer = preload("res://assets/scripts/timers.gd").new(self)

func _process(delta):
    hud.update_resources_panel(sausage, beer)

    if angle_y != _angle_y:
        _angle_y += (angle_y - _angle_y) * delta * 10.0

        var basis = Basis(Vector3(0.0, 1.0, 0.0), deg2rad(_angle_y))
        transform.basis = basis

    if move_to != transform.origin:
        var new_origin = transform.origin
        move_to.y = 0.0
        new_origin = transform.origin + (move_to - transform.origin) * delta * 10.0
        if world.get_height(new_origin, true) > world.SHALLOWS_LINE * world.MAP_HEIGHT_FACTOR:
            new_origin = transform.origin
            move_to = new_origin

        new_origin.y = transform.origin.y
        transform.origin = new_origin



func _input(event):
    if Input.is_action_pressed("game_left"):
        angle_y += rotate_speed
    if Input.is_action_pressed("game_right"):
        angle_y -= rotate_speed
    if Input.is_action_pressed("game_up"):
        var front_back = transform.basis.z
        front_back.y = 0.0
        front_back = front_back.normalized()
        move_to -= front_back * move_speed
    if Input.is_action_pressed("game_down"):
        var front_back = transform.basis.z
        front_back.y = 0.0
        front_back = front_back.normalized()
        move_to += front_back * move_speed
    if Input.is_key_pressed(KEY_ESCAPE):
        quit_game()
    if active_camera != 3 and active_camera != 4:
        if Input.is_action_pressed("game_a"):
            select_a()
        if Input.is_action_pressed("fire_garbage"):
            fire_garbage()
        if Input.is_action_pressed("fire_party"):
            fire_boarding_party()
        if Input.is_action_pressed("game_x"):
            use_smokescreen()
        if Input.is_action_pressed("game_y"):
            use_noisemaker()
    if Input.is_action_pressed("game_b"):
        select_b()
    if Input.is_action_pressed("game_pro"):
        select_pro()
    if Input.is_action_pressed("fire_garbage"):
        fire_garbage()

func _physics_process(delta):
    axis_value.x = Input.get_joy_axis(0, JOY_ANALOG_LX)
    axis_value.y = Input.get_joy_axis(0, JOY_ANALOG_LY)

    var current_axis = axis_value

    if active_camera == 3 or active_camera == 4:
        return

    if active_camera < 2:
        current_axis = current_axis.rotated(deg2rad(-pivot_point.angle_y))

    if abs(current_axis.x) > DEADZONE:
        angle_y -= rotate_speed * current_axis.x
        pivot_point.angle_y += rotate_speed * current_axis.x

    if abs(current_axis.y) > DEADZONE:
        if current_axis.y > 0:
            current_axis.y *= reverse_speed_multiplier
        var front_back = transform.basis.z
        front_back.y = 0.0
        front_back = front_back.normalized()
        move_to += front_back * move_speed_fb * current_axis.y

    garbage_stagger_timer += delta
    $smoke.emitting = smokescreen_effect


func select_a():
    print(transform.origin)


func select_b():
    cameras[active_camera].hide()
    active_camera += 1
    if active_camera > cameras.size() -1:
        active_camera = 0
    cameras[active_camera].show()
    cameras[active_camera].set_current(true)

    if active_camera == 3:
        camp.cursor_node.show()
        camp.add_ghost()
        hud.show_camp_hud()
    else:
        camp.cursor_node.hide()
        camp.clear_ghost()
        hud.hide_camp_hud()

func fire_garbage():
    if self.garbage_charges < 1 or active_camera == 3:
        return

    if garbage_stagger_timer < garbage_stagger:
        return

    garbage_stagger_timer = 0.0

    var direction = Vector2(0.0, -1.0)
    var elevation = 2

    if active_camera == 0 or active_camera == 1:
        direction = direction.rotated(deg2rad(-pivot_point.angle_y - angle_y))
    if active_camera == 1:
        elevation = 15
    if active_camera == 2:
        direction = direction.rotated(deg2rad(-angle_y))

    var new_garbage = projectile_template.instance()
    new_garbage.direction = Vector3(direction.x, 0.0, direction.y)
    new_garbage.transform.origin = Vector3(self.transform.origin.x, self.transform.origin.y + elevation, self.transform.origin.z)
    world.add_child(new_garbage)

    garbage_charges -= 1
    self.timer.set_timeout(garbage_recharge, self, "add_garbage")

    return new_garbage

func add_garbage():
    garbage_charges += 1

func select_pro():
    get_parent().get_node("sun").shadow_enabled = true

func quit_game():
    get_tree().quit()

func check_resources(sausage_amount, beer_amount):
    if sausage >= sausage_amount and beer >= beer_amount:
        return true
    return false

func add_resources(sausage_amount, beer_amount):
    sausage = sausage + sausage_amount
    beer = beer + beer_amount

func take_resources(sausage_amount, beer_amount):
    sausage = sausage - sausage_amount
    beer = beer - beer_amount

func hit_by_garbage():
    $hit.emitting = true


func fire_boarding_party():
    if not boarding_party or active_camera == 3:
        return

    if not check_resources(0, boarding_party_cost):
        return

    take_resources(0, boarding_party_cost)

    boarding_party = false

    var direction = Vector2(0.0, -1.0)
    var elevation = 0
    var angle

    if active_camera == 0 or active_camera == 1:
        angle = deg2rad(-pivot_point.angle_y - angle_y)
    if active_camera == 2:
        angle = deg2rad(-angle_y)
    direction = direction.rotated(angle)

    var new_party = boarding_party_template.instance()
    new_party.direction = Vector3(direction.x, 0.0, direction.y)
    new_party.transform.origin = Vector3(self.transform.origin.x, self.transform.origin.y + elevation, self.transform.origin.z)
    world.add_child(new_party)
    self.timer.set_timeout(boarding_party_recharge, self, "boarding_party_returns")

    var basis = Basis(Vector3(0.0, 1.0, 0.0), -angle)
    new_party.transform.basis = basis

    return new_party

func boarding_party_returns():
    boarding_party = true


func use_smokescreen():
    if not smokescreen or active_camera == 3:
        return

    if not check_resources(0, smokescreen_cost):
        return

    take_resources(0, smokescreen_cost)
    
    smokescreen_effect = true
    smokescreen = false

    self.timer.set_timeout(smokescreen_duration, self, "end_smokescreen")
    self.timer.set_timeout(smokescreen_recharge, self, "cool_smokescreen")
    
func end_smokescreen():
    smokescreen_effect = false

func cool_smokescreen():
    smokescreen = true


func use_noisemaker():
    if not noisemaker or active_camera == 3:
        return

    if not check_resources(0, noisemaker_cost):
        return

    take_resources(0, noisemaker_cost)

    noisemaker = false

    var player_position = Vector2(transform.origin.x, transform.origin.z)
    var ship
    var ship_position
    for identifier in world.spawned_ships:
        ship = world.spawned_ships[identifier]
        ship_position = Vector2(ship.transform.origin.x, ship.transform.origin.z)

        if player_position.distance_to(ship_position) < noisemaker_range:
            ship.noisemaker_effect = true

    self.timer.set_timeout(noisemaker_duration, self, "end_noisemaker")
    self.timer.set_timeout(noisemaker_recharge, self, "cool_noisemaker")


func end_noisemaker():
    for identifier in world.spawned_ships:
        world.spawned_ships[identifier].noisemaker_effect = false

func cool_noisemaker():
    noisemaker = true
