extends Spell

@export var freezeTime_per_level:Array[float]

var startPos:Vector2
var spawnNum:int = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	print("go")
	super._ready()
	
	startPos = position
	
	var theta:float = direction.angle()
	
	if (spawnNum == 4): theta += PI/6
	else: theta -= PI/12
		
	print(theta)
	rotation = theta
	direction = Vector2(cos(theta),sin(theta))
	
	if (spawnNum > 0):
		print("instanciate")
		var frozenArrows:PackedScene = load("res://src/spells/frozen_arrow.tscn")
		var frozen_arrows_instance:Spell = frozenArrows.instantiate()
		
		frozen_arrows_instance.spawnNum = spawnNum-1
		frozen_arrows_instance.direction = direction
		frozen_arrows_instance.position = startPos
		frozen_arrows_instance.level = level
		
		get_parent().add_child(frozen_arrows_instance)


func _on_hit(bodyType:String, body:Node2D):
	if (bodyType == "entity"):
		var entity:Entity = body
		entity.get_node("freezeTimer").start(freezeTime_per_level[level])
		entity.state = "freeze"
		if (entity.ranged):
			entity.canShoot = false
