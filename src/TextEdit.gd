extends TextEdit

signal name_found(name:String)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_pressed("Enter") && !text.is_empty()): name_found.emit(text)
