extends Node2D
class_name PopupText

var text:String
var textColor:String
var duration:float = -1
var speed:float = 300.0
var direction:Vector2 = Vector2.UP

# Called when the node enters the scene tree for the first time.
func _ready():
	if textColor == "gray":
		$health_counter_gray.text = text
	elif textColor == "red":
		$health_counter_red.text = text
	elif textColor == "yellow":
		$health_counter_yellow.text = text
	elif textColor == "blue":
		$health_counter_blue.text = text
	$lifeTimer.start(duration)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += direction * speed * delta


func _on_life_timer_timeout():
	queue_free()
