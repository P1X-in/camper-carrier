extends Position3D

export var rotate_speed = 1.0
export var return_speed = 1.0

const DEADZONE = 0.25

var angle_y = 0

var _angle_y = 0

var axis_value
var axis_abs

var cumulative = 0

func _process(delta):
    if angle_y != _angle_y:
        _angle_y += (angle_y - _angle_y) * delta * 10.0
        if abs(angle_y - _angle_y) < 0.001:
            _angle_y = angle_y

        var basis = Basis(Vector3(0.0, 1.0, 0.0), deg2rad(_angle_y))
        transform.basis = basis


func _physics_process(delta):
    for axis in range(JOY_AXIS_0, JOY_AXIS_MAX):
        axis_value = Input.get_joy_axis(0, axis)
        axis_abs = abs(axis_value)
        if axis_abs > DEADZONE:
            # ROTATE LEFT - RIGHT
            if axis == JOY_ANALOG_RX:
                angle_y -= rotate_speed * axis_value
                cumulative = 0

            #if axis == JOY_ANALOG_LY:
            #    var rotation_axis_value = Input.get_joy_axis(0, JOY_ANALOG_RX)
            #    if abs(rotation_axis_value) < DEADZONE and cumulative > 0.5:
            #        if axis_value > 0:
            #            angle_y = 180
            #        else:
            #            angle_y = 0
            #    else:
            #        cumulative += delta



