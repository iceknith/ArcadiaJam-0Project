extends Spell

@export var min_mob_count = 1
@export var max_mob_count = 2

var parent:Entity
var mobs:Array[PackedScene] = [
	load("res://src/entities/imp.tscn"),
	load("res://src/entities/naga.tscn"),
	load("res://src/entities/rat.tscn"),
	load("res://src/entities/tax_inspector.tscn"),
	load("res://src/entities/naga_shaman.tscn"),
	load("res://src/entities/zombie.tscn")
	]


# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in range(randi_range(min_mob_count, max_mob_count)):
		var new_mob:Entity = mobs.pick_random().instantiate()
		new_mob.position = position
		new_mob.target = parent.target
		get_parent().add_child(new_mob)
	
	queue_free()
