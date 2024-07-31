extends Node2D

signal player_in_same_room(player)

@export var minEntities:int = 2
@export var maxEntities:int = 10
var level
var roomHP:float
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
	
	print("roomHP:",roomHP)
	#add entities to room, so that it comes near to the roomHP
	var haveFoundMob:bool = true
	var activeRoommHP:int  = 0
	while haveFoundMob && activeRoommHP < roomHP:
		haveFoundMob = false
		entitiesList[level].shuffle()
		for entity_scene:PackedScene in entitiesList[level]:
			var entity:Entity = entity_scene.instantiate()
			if (activeRoommHP + entity.damageToKill < roomHP * 1.2):
				activeRoommHP += entity.damageToKill
				entity.level = 0
				entity.position = positions.pick_random()
				player_in_same_room.connect(entity._on_player_in_same_room)
				get_parent().add_child.call_deferred(entity)
				haveFoundMob = true
				break
			entity.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_player_entered_first_time(player):
	player_in_same_room.emit(player)
