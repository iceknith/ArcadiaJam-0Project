extends "res://addons/onscreenkeyboard/onscreen_keyboard.gd"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (get_parent().is_visible_in_tree() && !visible):
		show()
		get_children()[0].get_children()[0].get_children()[0].get_children()[0].grab_focus()

func _update_auto_display_on_input(event):
	super._update_auto_display_on_input(event)
