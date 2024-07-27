extends Area2D
class_name Room

signal player_entered_first_time(player:Player)

@export var num_entries:int = 4
@export var isCorridor:bool = false
@export var hasMobs:bool = false
@export var check_if_open_door_time = 1.0

@export var loot:Array = [preload("res://src/items/heal_gray.tscn"),
						preload("res://src/items/heal_red.tscn"),
						preload("res://src/items/heal_yellow.tscn"),
						preload("res://src/items/heal_blue.tscn")]
						
@export var minHeal:float = 0.4
@export var maxHeal:float = 0.8

var player:Player
var playerEntered:bool = false
var doorClosed:bool = false
var collisionRect:Rect2;
var entries_dir:Array = []
var door_to_close:Array = []
var walls:Array = []

var openDoorTimer = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	collisionRect = $CollisionShape2D.get_shape().get_rect();
	
	num_entries = clamp(num_entries, 0, 4)
	for i:int in range(num_entries):
		if (get_node_or_null(str("entry",i+1)) == null):
			push_error(str("entry",i+1,". Missing from room object"))
		else:
			entries_dir.append([])
			entries_dir[i].append(2*get_node(str("entry",i+1)).position)
			
			if (abs(entries_dir[i][0].x/collisionRect.size.x) == 1):
				entries_dir[i].append(Vector2(entries_dir[i][0].x/collisionRect.size.x, 0))
			else:
				entries_dir[i].append(Vector2(0, entries_dir[i][0].y/collisionRect.size.y))
				

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (doorClosed):
		openDoorTimer += delta
		if (openDoorTimer >= check_if_open_door_time):
			openDoorTimer = 0
			if (!has_entities()):
				doorClosed = false
				open_doors()

func _on_body_entered(body):
	if ("player" in body.name && !playerEntered):
		player = body
		player_entered_first_time.emit(player)
		playerEntered = true
		if (hasMobs):
			doorClosed = true
			close_doors()
			if (!player.firstAttackMob):
				player.firstAttackMob = true
				player.showTutorial.emit("mob")
		
func close_doors():
	var i:int = 0
	for direction in door_to_close:
		i+=1
		var wall:Node2D
		if direction[1].x == -1:
			wall = walls[0].instantiate()
		elif direction[1].x == 1:
			wall = walls[1].instantiate()
		elif direction[1].y == 1:
			wall = walls[2].instantiate()
		elif direction[1].y == -1:
			wall = walls[3].instantiate()
		
		wall.name = str("wall_",i)
		wall.z_index = 5
		wall.position = direction[0]/2
		add_child(wall)
	
func open_doors():
	for child in get_children():
		if "wall" in child.name: child.queue_free()
	
	if (hasMobs):
		var lootStat = player_get_needed_colors().pick_random()
		var lootItem:Item = loot[lootStat[0]].instantiate()
		lootItem.healAmount = lootStat[1]
		lootItem.position = get_node("LootPosition").position
		add_child(lootItem)

func has_entities()->bool:
	for child in get_children():
		for grand_children in child.get_children():
			if ("hit_hitbox" in grand_children.name && child.state != "dead"):
				return true
	return false

func dungeon_finished(player):
	get_node("FinishTimer").start()

func remove_entities():
	if (!hasMobs): return
	hasMobs = false
	
	for child in get_children():
		var deleteChild = false
		for grand_children in child.get_children():
			if ("hit_hitbox" in grand_children.name):
				deleteChild = true
				break
		if (deleteChild): 
			child.queue_free()

func player_get_needed_colors()->Array:
	var result:Array = []
	
	if player == null: return result
	
	if (player.red < player.maxRed):
		result.append([1, int(player.maxRed * randf_range(minHeal, maxHeal))+0.3])
	if (player.yellow < player.maxYellow):
		result.append([2, int(player.maxYellow * randf_range(minHeal, maxHeal))+0.3])
	if (player.blue < player.maxBlue):
		result.append([3, int(player.maxBlue * randf_range(minHeal, maxHeal))+0.3])
	if (result.is_empty()):
		result.append([0, int(player.maxGray * randf_range(minHeal, maxHeal))+0.3])
	
	return result

func _on_finish_timer_timeout():
	for body in get_overlapping_bodies():
		if ("player" in body.name):
			get_parent().get_parent().nextLevel.call_deferred()
	playerEntered = false
