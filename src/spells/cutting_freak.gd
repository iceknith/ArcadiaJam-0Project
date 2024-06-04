extends Spell

@export var duration_per_level:Array[float] = []
@export var damageAdd_per_level:Array[float] = []

var playerPrevDamage

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	player.is_buffed = true
	playerPrevDamage = player.additionalStabDamage
	player.additionalStabDamage += damageAdd_per_level[level]
	print("aaa")
	$Timer.start(duration_per_level[level])


func _on_timer_timeout():
	print("ohio")
	player.is_buffed = false
	player.additionalStabDamage = playerPrevDamage
	queue_free()
