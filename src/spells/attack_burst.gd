extends Spell

@export var duration_per_level:Array[float] = []
@export var player_damage_mult_per_level:Array[float] = []

var playerDamageMult

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	player.is_buffed = true
	playerDamageMult = player.damageMultiplier * player_damage_mult_per_level[level]
	player.damageMultiplier += playerDamageMult
	$Timer.start(duration_per_level[level])


func _on_timer_timeout():
	player.is_buffed = false
	player.damageMultiplier -= playerDamageMult
	queue_free()
