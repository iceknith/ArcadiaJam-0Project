extends Node2D

signal player_in_same_room(player)

@export var entitiesList:Array[PackedScene]
@export var minEntities:int = 0
@export var maxEntities:int = 0

var positions:Array[Vector2] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if (child.is_class("Marker2D")):
			positions.append(child.position)
	for i in randi_range(minEntities, maxEntities):
		var entity:Entity = entitiesList.pick_random().instantiate()
		entity.position = positions.pick_random()
		player_in_same_room.connect(entity._on_player_in_same_room)
		get_parent().add_child.call_deferred(entity)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_player_entered_first_time(player):
	player_in_same_room.emit(player)
