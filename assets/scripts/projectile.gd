extends Position3D

export var move_speed = 10.0

var world
var direction = Vector3(0.0, 0.0, 0.0)
var hostile = false

func _ready():
    world = get_parent()

func _process(delta):
    var new_origin = transform.origin
    new_origin = transform.origin + direction * move_speed * delta * 10.0
    if world.get_height(new_origin, true) > (world.BLUE_LINE + 0.05) * world.MAP_HEIGHT_FACTOR:
        new_origin = transform.origin
        queue_free()

    new_origin.y = transform.origin.y
    transform.origin = new_origin

func _physics_process(delta):
    var ship
    var ship_position
    var projectile_position = Vector2(transform.origin.x, transform.origin.z)

    if not hostile:
        for identifier in world.spawned_ships:
            ship = world.spawned_ships[identifier]
            ship_position = Vector2(ship.transform.origin.x, ship.transform.origin.z)

            if projectile_position.distance_to(ship_position) < ship.hitbox_size:
                ship.hit_by_garbage()
                queue_free()
                return
    else:
        ship = world.player
        ship_position = Vector2(ship.transform.origin.x, ship.transform.origin.z)
        if projectile_position.distance_to(ship_position) < ship.hitbox_size:
            ship.hit_by_garbage()
            queue_free()
