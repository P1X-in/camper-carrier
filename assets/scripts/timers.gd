
var container

var pool = {}

func _init(container):
    self.container = container

func set_timeout(timeout, object, method, args=[]):
    var timer = self.get_next_timer()
    timer.set_wait_time(timeout)
    timer.set_one_shot(true)
    timer.connect("timeout", self, "execute_timeout", [object, method, args, timer])
    self.container.add_child(timer)
    timer.start()

func execute_timeout(object, method, args, timer):
    self.container.remove_child(timer)
    timer.disconnect("timeout", self, "execute_timeout")

    if args.size() == 1:
        object.call(method, args[0])
    elif args.size() > 1:
        object.call(method, args)
    else:
        object.call(method)

    self.pool[timer.get_instance_id()] = timer

func get_next_timer():
    var timer = null
    for timer_id in self.pool:
        timer = self.pool[timer_id]

    if timer != null:
        self.pool.erase(timer.get_instance_id())
        return timer

    return Timer.new()
