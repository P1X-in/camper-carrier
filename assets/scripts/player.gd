extends Position3D

export var rotate_speed = 0.5
export var move_speed = 1.0
export var move_speed_lr = 0.5
export var move_speed_fb = 0.5
export var reverse_speed_multiplier = 0.4
export var hitbox_size = 3.0
export var barrel_pickup_range = 10.0

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

var dead = preload("res://assets/scenes/dead_ship.tscn").instance()

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
var got_hit = false

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
    schedule_regen()
    update_hud_hp()

func _process(delta):
    if current_hp == 0:
        return

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
    if Input.is_key_pressed(KEY_ESCAPE):
        quit_game()
    if Input.is_action_pressed("game_pro"):
        select_pro()

    if current_hp == 0:
        return

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
    if Input.is_action_pressed("dpad_up"):
        main_screen_on()
    if Input.is_action_pressed("dpad_down"):
        what_is_going_on()
    if Input.is_action_pressed("dpad_left"):
        get_to_work()
    if Input.is_action_pressed("dpad_right"):
        party_mode()

func _physics_process(delta):
    if current_hp == 0:
        return

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
    pickup_barrels()

func pickup_barrels():
    var player_position = Vector2(transform.origin.x, transform.origin.z)
    var barrel
    var barrel_position
    for identifier in world.spawned_barrels:
        barrel = world.spawned_barrels[identifier]
        barrel_position = Vector2(barrel.transform.origin.x, barrel.transform.origin.z)

        if player_position.distance_to(barrel_position) < barrel_pickup_range:
            barrel.destroyed()


func select_a():
    print(transform.origin)


func select_b():
    if active_camera == 0:
        select_camera(1)
    elif active_camera == 1:
        select_camera(0)

func main_screen_on():
    select_camera(0)

func party_mode():
    select_camera(2)

func get_to_work():
    select_camera(3)

func what_is_going_on():
    select_camera(4)


func select_camera(index):
    cameras[active_camera].hide()
    active_camera = index
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

func update_hud_icons():
    if hud == null:
        return

    if smokescreen:
        hud.smokescreen.show()
    else:
        hud.smokescreen.hide()
    hud.smokescreen_label.set_value(smokescreen_cost)

    if noisemaker:
        hud.noisemaker.show()
    else:
        hud.noisemaker.hide()
    hud.noisemaker_label.set_value(noisemaker_cost)

    if boarding_party:
        hud.boarding_party.show()
    else:
        hud.boarding_party.hide()
    hud.boarding_party_label.set_value(boarding_party_cost)

func update_hud_hp():
    if hud == null:
        return

    hud.update_hp(current_hp, hp)

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
    if current_hp == 0:
        return

    got_hit = true
    current_hp -= 1
    update_hud_hp()
    $hit.emitting = true
    print("HP reduced to ", current_hp)
    if current_hp == 0:
        destroyed()

func destroyed():
    world.add_child(dead)
    dead.transform.origin = transform.origin
    hide()


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

    update_hud_icons()

    return new_party

func boarding_party_returns():
    boarding_party = true
    update_hud_icons()

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
    update_hud_icons()

func end_smokescreen():
    smokescreen_effect = false

func cool_smokescreen():
    smokescreen = true
    update_hud_icons()


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
    update_hud_icons()


func end_noisemaker():
    for identifier in world.spawned_ships:
        world.spawned_ships[identifier].noisemaker_effect = false

func cool_noisemaker():
    noisemaker = true
    update_hud_icons()

func schedule_regen():
    self.timer.set_timeout(10, self, "regen_hp")

func regen_hp():
    if current_hp > 0 and current_hp < hp and not got_hit:
        current_hp += 1
    got_hit = false

    schedule_regen()
