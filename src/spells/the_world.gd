extends Spell

@export var freezeTime_per_level:Array[float]

func _on_hit(bodyType:String, body:Node2D):
	if (bodyType == "entity"):
		var entity:Entity = body
		entity.get_node("freezeTimer").start(freezeTime_per_level[level])
		entity.state = "freeze"
		if (entity.ranged):
			entity.canShoot = false
