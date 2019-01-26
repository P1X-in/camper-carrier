extends MeshInstance

func get_level(num):
    return self.get_node("level" + str(num))

func get_basic():
    return self.get_level(1)

func get_upgrade(current_level):
    return self.get_level(current_level + 1)
