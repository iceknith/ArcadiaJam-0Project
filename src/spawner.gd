extends Node2D

signal player_in_same_room(player)

@export var minEntities:int = 2
@export var maxEntities:int = 10
var level
var difficulty:float

var entitiesList:Array[Array] = [
	[load("res://src/entities/zombie.tscn"),
	load("res://src/entities/mib.tscn"),
	load("res://src/entities/rat.tscn"),
	load("res://src/entities/tax_inspector.tscn")], 
	
	[load("res://src/entities/scorpion.tscn"),
	load("res://src/entities/naga_shaman.tscn"),
	load("res://src/entities/naga.tscn"),
	load("res://src/entities/shaman.tscn"),
	load("res://src/entities/tax_inspector.tscn"),
	load("res://src/entities/scorpion.tscn")], 
	
	[load("res://src/entities/imp.tscn"),
	load("res://src/entities/rat.tscn"),
	load("res://src/entities/tax_inspector.tscn"),
	load("res://src/entities/naga.tscn"),
	load("res://src/entities/naga_shaman.tscn"),
	load("res://src/entities/scorpion.tscn")]
	]

var positions:Array[Vector2] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if (child.is_class("Marker2D")):
			positions.append(child.position)
	for i in int(minEntities + clampf(randf_range(difficulty*0.9, difficulty*1.1), 0, 1)*(maxEntities - minEntities)/2.5):
		var entity:Entity = entitiesList[level].pick_random().instantiate()
		entity.position = positions.pick_random()
		entity.level = difficulty
		player_in_same_room.connect(entity._on_player_in_same_room)
		get_parent().add_child.call_deferred(entity)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_player_entered_first_time(player):
	player_in_same_room.emit(player)
