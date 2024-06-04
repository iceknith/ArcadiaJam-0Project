extends Spell

@export var duration_per_level:Array[float] = []
@export var dash_duration_percent_per_level:Array[float] = []

var playerDashTimeAdded

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	player.is_buffed = true
	playerDashTimeAdded = player.dashDuration * dash_duration_percent_per_level[level]
	player.dashDuration += playerDashTimeAdded
	$Timer.start(duration_per_level[level])


func _on_timer_timeout():
	player.is_buffed = false
	player.dashDuration -= playerDashTimeAdded
	queue_free()
