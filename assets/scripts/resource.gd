extends Label

var value = 0

func set_value(value):
	set_text(str(value).pad_zeros(3))