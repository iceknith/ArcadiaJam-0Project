extends Button

var was_active = false

func _process(delta):
	if (!was_active && visible):
		was_active = true
		grab_focus()
