extends Spell

@export var duration_per_level:Array[float] = []
@export var speed_percent_per_level:Array[float] = []

var playerSpeedAdded

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	player.is_buffed = true
	playerSpeedAdded = player.speed * speed_percent_per_level[level]
	player.speed += playerSpeedAdded
	$Timer.start(duration_per_level[level])


func _on_timer_timeout():
	player.is_buffed = false
	player.speed -= playerSpeedAdded
	queue_free()
