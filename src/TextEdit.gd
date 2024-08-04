extends TextEdit

signal name_found(name:String)

@export var max_name_size:int = 15
var current_text:String = ""
var current_column:int = 0

func _ready():
	focus_mode = FOCUS_NONE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_pressed("Enter") && !text.is_empty()): name_found.emit(text)

func _on_text_changed():
	if "\n" in text: 
		name_found.emit(text.replace("\n", ""))
		return
		
	if (text.length() > max_name_size):
		text = current_text
		set_caret_column(current_column)
		
	else:
		current_text = text
		current_column = get_caret_column()


func _on_onscreen_keyboard_key_pressed(unicode_value:int):
	_handle_unicode_input(unicode_value, 0)
	

func _handle_unicode_input(unicode_value:int, caret_index:int):
	#handling every case
	var caret_column:int = get_caret_column(caret_index)
	if (unicode_value == KEY_BACKSPACE): 
		if (caret_column > 0):
			text = text.erase(caret_column - 1, 1)
			set_caret_column(caret_column-1, true, caret_index)
	elif (unicode_value == KEY_LEFT): 
		set_caret_column(max(0, caret_column - 1), true, caret_index)
	elif (unicode_value == KEY_RIGHT): 
		set_caret_column(min(text.length(), caret_column + 1), true, caret_index)
	elif (unicode_value == KEY_ENTER && !text.is_empty()):
		name_found.emit(text)
	elif (unicode_value != KEY_SHIFT): 
		insert_text_at_caret(char(unicode_value), caret_index)
