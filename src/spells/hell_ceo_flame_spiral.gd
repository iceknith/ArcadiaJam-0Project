extends Spell

@export var flames_per_circle:int = 10
@export var max_flame_number:int = 11

var flame_count:int = max_flame_number
var init_pos:Vector2
var parent:CharacterBody2D

func _on_spawn_new_flame_timeout():
	if (flame_count <= 0 || !is_instance_valid(parent)): return
	
	var new_rotation:float = rotation + 2*PI/flames_per_circle
	var new_flame:Spell = load("res://src/spells/hell_ceo_flame_spiral.tscn").instantiate()
	new_flame.flame_count = flame_count - 1
	new_flame.position = parent.position
	new_flame.parent = parent
	new_flame.direction = Vector2(cos(new_rotation), sin(new_rotation))
	get_parent().add_child(new_flame)

