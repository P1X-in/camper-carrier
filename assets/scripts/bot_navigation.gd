
var navigation = {}

var offset = -2048

var pairs = [
    [Vector2(1988, 2150), Vector2(1476, 2424)],
    [Vector2(1476, 2424), Vector2(1408, 2076)],
    [Vector2(1408, 2076), Vector2(1564, 1900)],
    [Vector2(1564, 1900), Vector2(1988, 2150)],

    [Vector2(1988, 2150), Vector2(2368, 2576)],
    [Vector2(2368, 2576), Vector2(2444, 2944)],
    [Vector2(2444, 2944), Vector2(2208, 3348)],
    [Vector2(2208, 3348), Vector2(1316, 3432)],

    [Vector2(1316, 3432), Vector2(904, 3628)],
    [Vector2(904, 3628), Vector2(660, 3532)],
    [Vector2(660, 3532), Vector2(612, 3148)],
    [Vector2(612, 3148), Vector2(828, 2708)],
    [Vector2(828, 2708), Vector2(1316, 3432)],

    [Vector2(828, 2708), Vector2(764, 2116)],

    [Vector2(764, 2116), Vector2(592, 1812)],
    [Vector2(592, 1812), Vector2(504, 1160)],
    [Vector2(504, 1160), Vector2(748, 884)],
    [Vector2(748, 884), Vector2(976, 1164)],
    [Vector2(976, 1164), Vector2(928, 1800)],
    [Vector2(928, 1800), Vector2(764, 2116)],

    [Vector2(748, 884), Vector2(1316, 604)],
    [Vector2(1316, 604), Vector2(1792, 964)],
    [Vector2(1792, 964), Vector2(2512, 648)],

    [Vector2(2512, 648), Vector2(2888, 596)],
    [Vector2(2888, 596), Vector2(3108, 776)],
    [Vector2(3108, 776), Vector2(3048, 1108)],
    [Vector2(3048, 1108), Vector2(2724, 988)],
    [Vector2(2724, 988), Vector2(2512, 648)],

    [Vector2(3108, 776), Vector2(3600, 616)],
    [Vector2(3600, 616), Vector2(3708, 1052)],
    [Vector2(3708, 1052), Vector2(3428, 1676)],
    [Vector2(3428, 1676), Vector2(3048, 1108)],

    [Vector2(3428, 1676), Vector2(3652, 1976)],
    [Vector2(3652, 1976), Vector2(3400, 2536)],
    [Vector2(3400, 2536), Vector2(3204, 2196)],
    [Vector2(3204, 2196), Vector2(2912, 2060)],
    [Vector2(2912, 2060), Vector2(3428, 1676)],

    [Vector2(3400, 2536), Vector2(3084, 3068)],
    [Vector2(3084, 3068), Vector2(2852, 3524)],
    [Vector2(2852, 3524), Vector2(2660, 3728)],
    [Vector2(2660, 3728), Vector2(2384, 3740)],
    [Vector2(2384, 3740), Vector2(2208, 3348)],

    [Vector2(2912, 2060), Vector2(2368, 2576)],
    [Vector2(2912, 2060), Vector2(2308, 1796)],
    [Vector2(2308, 1796), Vector2(1988, 2150)],
    [Vector2(2308, 1796), Vector2(1792, 964)],
]

func _init():
    for pair in pairs:
        pair[0] = pair[0] + Vector2(offset, offset)
        pair[1] = pair[1] + Vector2(offset, offset)
        add_pair(pair[0], pair[1])

func get_key(point):
    return str(point.x) + "_" + str(point.y)

func add_pair(x, y):
    var x_key = get_key(x)
    var y_key = get_key(y)
    if navigation.has(x_key):
        navigation[x_key].append(y)
    else:
        navigation[x_key] = [y]

    if navigation.has(y_key):
        navigation[y_key].append(x)
    else:
        navigation[y_key] = [x]

func get_points(current, previous):
    var possible_destinations = navigation[get_key(current)]

    if previous != null:
        possible_destinations.erase(previous)

    return possible_destinations
