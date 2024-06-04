extends Spell

@export var arrow_num:int = 4
@export var directions:Array[Vector2] = [Vector2.UP, Vector2.LEFT, Vector2.RIGHT, Vector2.DOWN]
@export var freezeTime_per_level:Array[float]

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	var frozenArrows:PackedScene = load("res://src/spells/frozen_arrow.tscn")
	for i in arrow_num-1:
		var frozen_arrow_instance:Spell = frozenArrows.instantiate()
		frozen_arrow_instance.arrow_num = 0
		frozen_arrow_instance.direction = directions[i]
		frozen_arrow_instance.position = position
		get_parent().add_child(frozen_arrow_instance)
	if (arrow_num != 0):
		direction = directions[arrow_num - 1]
		rotation = atan(direction.y/direction.x)


func _on_hit(bodyType:String, body:Node2D):
	if (bodyType == "entity"):
		var entity:Entity = body
		entity.get_node("freezeTimer").start(freezeTime_per_level[level])
		entity.state = "freeze"
		if (entity.ranged):
			entity.canShoot = false
