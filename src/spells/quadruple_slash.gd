extends Spell

var startPos:Vector2
var spawnNum:int = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	if (spawnNum > 0):
		startPos = position
		$Timer.start()
	
	var theta:float = direction.angle()
	
	if (spawnNum == 3): theta += 3*PI/24
	else: theta -= PI/12
		
	print(theta)
		
	rotation = theta
	direction = Vector2(cos(theta),sin(theta))
		


func _on_timer_timeout():
	var quadruple_slash:PackedScene = load("res://src/spells/quadruple_slash.tscn")
	var quadruple_slash_instance:Spell = quadruple_slash.instantiate()

	quadruple_slash_instance.direction = direction
	quadruple_slash_instance.position = startPos
	quadruple_slash_instance.spawnNum = spawnNum - 1
	get_parent().add_child(quadruple_slash_instance)
