extends Spell

var startPos:Vector2
var spawnNum:int = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	if (spawnNum > 0):
		startPos = position
		$Timer.start()

func _on_timer_timeout():
	var quadruple_slash:PackedScene = load("res://src/spells/quadruple_slash.tscn")
	var quadruple_slash_instance:Spell = quadruple_slash.instantiate()
	quadruple_slash_instance.direction = direction
	quadruple_slash_instance.position = startPos
	quadruple_slash_instance.spawnNum = spawnNum - 1
	print(spawnNum)
	get_parent().add_child(quadruple_slash_instance)
