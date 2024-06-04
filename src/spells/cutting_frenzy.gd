extends Spell

@export var duration_per_level:Array[float] = []

var playerPrevSlashCost

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	player.is_buffed = true
	playerPrevSlashCost = player.stabCost
	player.stabCost = 0
	$Timer.start(duration_per_level[level])


func _on_timer_timeout():
	player.is_buffed = false
	player.stabCost = playerPrevSlashCost
	queue_free()
