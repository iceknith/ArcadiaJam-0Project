extends Node2D

var rooms:Array = [];
var corridors:Array = [];
var walls:Array = []
var shopRooms:Array = []
var finishRooms:Array = []
var grid:Array = [];

@export var default_room_cnt:int = 5
@export var max_room_to_corridor = 1
@export var minRoomToShop:int = 2
@export var maxRoomToShop:int = 4

@export var spellMinDamage:int = 10
@export var spellMaxDamage:int = 60

@export var roomHealTolerance:float = -0.1

var world = 1
var visited_worlds = 1;

# Called when the node enters the scene tree for the first time.
func _ready():
	var file = DirAccess.open("res://src/rooms/")
	
	var i = 1;
	var world_dir = str("world",i)
	while file.dir_exists(world_dir):
		rooms.append([])
		corridors.append([])
		shopRooms.append([])
		finishRooms.append([])
		walls.append([null, null, null, null])
		
		var world_file = DirAccess.open(str("res://src/rooms/world",i))
		
		for room in world_file.get_files():
			if ".remap" in room:
				room = room.replace(".remap","")
			if "corridor" in room:
				corridors[i-1].append(load(str("res://src/rooms/world",i,"/",room)) as PackedScene)
			elif "wallLeft" in room: 
				walls[i-1][0] = load(str("res://src/rooms/world",i,"/",room)) as PackedScene
			elif "wallRight" in room: 
				walls[i-1][1] = load(str("res://src/rooms/world",i,"/",room)) as PackedScene
			elif "wallDown" in room: 
				walls[i-1][2] = load(str("res://src/rooms/world",i,"/",room)) as PackedScene
			elif "wallUp" in room: 
				walls[i-1][3] = load(str("res://src/rooms/world",i,"/",room)) as PackedScene
			elif "shopRoom" in room: 
				shopRooms[i-1].append(load(str("res://src/rooms/world",i,"/",room)) as PackedScene)
			elif "finishRoom" in room: 
				finishRooms[i-1].append(load(str("res://src/rooms/world",i,"/",room)) as PackedScene)
			else:
				rooms[i-1].append(load(str("res://src/rooms/world",i,"/",room)) as PackedScene)
		
		i+=1;
		world_dir = str("world",i)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func generateDungeon(worldNum:int, roomNum:int, player:Player):
	worldNum -= 1
	if worldNum > rooms.size():
		push_error("Invalid World num")
		
	#load background
	$ParallaxBackground/ParallaxLayer/Sprite2D.texture = load(str("res://assets/backgrounds/background_world_",worldNum+1,".png"))
	
	#generate dungeon
	var rooms_used:Array = rooms[worldNum]
	var corridor_used:Array = corridors[worldNum]
	
	var current_pix:Vector2 = Vector2.ZERO;
	var current_pos:Vector2 = Vector2.ZERO;
	var previous_dir:Array = [Vector2.ZERO, Vector2.UP]
	var previous_pos:Array = []
	var possible_dirs:Array = []
	var reverse_index:int = grid.size()
	
	var prevRoom:Room = null

	var room_to_corridor = max_room_to_corridor
	var room_to_shop = 0
	var i:int = 0
	
	#variables used for the generation of the dungeon
	#Maybe change the damage counting, because as it is now, it will count twice as much, if there are two spells using the same color
	var playerDamage:int = potentialDamage(player)
	
	while i < roomNum:
		i += 1
		
		var room:Room
		var current_dir:Array
		var found_room:bool = false
		
		var possible_rooms:Array
		if (i == roomNum):
			possible_rooms = finishRooms[worldNum].duplicate()
		elif (room_to_corridor == 0):
			possible_rooms = corridor_used.duplicate()
		elif (room_to_shop == 0):
			possible_rooms = shopRooms[worldNum].duplicate()
			room_to_shop = randi_range(minRoomToShop, maxRoomToShop)
		else:
			possible_rooms = rooms_used.duplicate()
		possible_rooms.shuffle()
		
		#Search for a valid room to insert in this space
		while !found_room && possible_rooms.size() > 0:
			
			room = possible_rooms.pop_front().instantiate()
			room.position = current_pix
			
			#change the mob count of the room
			if (room.hasMobs):
				room.get_node("spawner").level = worldNum
				room.get_node("spawner").roomHP = (pow((float)(i)/roomNum, 2) * (playerDamage/2) + (playerDamage/2)) * get_difficulty()
				room.damageHealed = (pow((float)(i)/roomNum, 2) * (playerDamage/2) + (playerDamage/2)) * (get_difficulty() + roomHealTolerance)
				#the player has roomHealTolerance % more damage "healed" than damage he theoretically has to cast
			#if the room is a shop
			elif (!room.isCorridor && i != roomNum):
				room.get_node("Shop").newSpellExpectedDamage = randi_range(spellMinDamage, spellMaxDamage)
				playerDamage += room.get_node("Shop").newSpellExpectedDamage
			add_child(room)
			
			possible_dirs = room.entries_dir.duplicate()
			
			possible_dirs.shuffle()
			#searching to see if the room connects to an existing room
			for dirs in possible_dirs:
				if dirs[1] == -previous_dir[1]:
					found_room = true
					if (i != 1): 
						room.door_to_close.append(dirs)
						room.entries_dir.erase(dirs)
					break
			#searching a possible direction
			if (found_room):
				current_dir = possible_dirs.pop_front()
				while (intersectsWithRoom(current_pos + current_dir[1], previous_pos)):
					if (possible_dirs.size() == 0):
						found_room = false;
						break;
					current_dir = possible_dirs.pop_front()
			
			#removing the room as it is not valid
			if (!found_room):
				remove_child(room)
		
		#If we couldn't spawn room
		if (!found_room):
			
			while !found_room:
				reverse_index -= 1
				found_room = true
				
				if reverse_index < 0:
					push_error("ERREUR: la génération du dongeon as échoué")
					return
				
				room = grid[reverse_index]
				current_pos = previous_pos[reverse_index]
				current_pix = room.position
				possible_dirs = room.entries_dir.duplicate()
				
				if (possible_dirs.size() == 0):
						found_room = false;
						continue;
				
				current_dir = possible_dirs.pop_front()
				while (intersectsWithRoom(current_pos + current_dir[1], previous_pos)):
					if (possible_dirs.size() == 0):
						found_room = false;
						break;
					current_dir = possible_dirs.pop_front()
			
			
			#If we did find a position, we update all the variables
			current_pix += current_dir[0]
			current_pos += current_dir[1]
			previous_dir = current_dir
			prevRoom = room
			room_to_corridor = 0
			i -= 1
			continue
			
		#Adding the room
		if (prevRoom != null): 
			prevRoom.door_to_close.append(previous_dir)
			prevRoom.entries_dir.erase(previous_dir)
		#changing the room counts
		room.walls = walls[worldNum]
		grid.append(room)
		previous_pos.append(current_pos);
		current_pix += current_dir[0]
		current_pos += current_dir[1]
		previous_dir = current_dir
		prevRoom = room
		reverse_index = grid.size()
		if (i == 1):
			get_parent().get_node("player").position = position + room.position + room.get_node("LootPosition").position
			room.remove_entities.call_deferred()
		
		if(!room.isCorridor): room_to_corridor -= 1
		else: room_to_corridor = max_room_to_corridor
		
		if (!room.isCorridor and room.hasMobs): room_to_shop -= 1
	
	#close rooms
	for room:Room in grid:
		for direction in room.entries_dir:
			var wall:Node2D
			if direction[1].x == -1:
				wall = walls[worldNum][0].instantiate()
			elif direction[1].x == 1:
				wall = walls[worldNum][1].instantiate()
			elif direction[1].y == 1:
				wall = walls[worldNum][2].instantiate()
			elif direction[1].y == -1:
				wall = walls[worldNum][3].instantiate()
				
			wall.position = room.position + direction[0]/2
			add_child(wall)

func intersectsWithRoom(position:Vector2, rooms_pos:Array)->bool:
	for room in rooms_pos:
		if position.x - room.x == 0 && position.y - room.y == 0:
			return true
	return false

func potentialDamage(player:Player)->int:
	var spells:Array[PackedScene] = player.spells.duplicate()
	spells.append(player.stab)
	var spell_levels:Array[int] = player.spell_levels.duplicate()
	spell_levels.append(0)
	
	var colorSpells:Array[int] = [0, 0, 0, 0, 0]
	var colorDamage:Array[int] = [0, 0, 0, 0, 0]
	var colors:Array[String] = ["gray", "blue", "red", "yellow"]
	
	for i in range(spells.size()):
		if spells[i] == null: continue
		var spell:Spell = spells[i].instantiate()
		var spell_level:int = spell_levels[i]
		for j in range(colors.size()):
			if colors[j] == spell.costType:
				colorDamage[j] += spell.damageAmount_per_level[spell_level] * player.get_color(colors[j]) / spell.costs_per_level[spell_level]
				colorSpells[j] += 1
				break
		spell.queue_free()
		
	var result:int = 0
	for i in range(colorDamage.size()):
		if colorSpells[i]:
			result += colorDamage[i]/colorSpells[i]
	return result

func generateNewDungeon(player:Player):
	deleteDungeon()
	generateDungeon(world, default_room_cnt, player)
	world = world%rooms.size() + 1
	visited_worlds += 1
	
func deleteDungeon():
	grid = []
	for child in get_children():
		if !("ParallaxBackground" in child.name):
			remove_child(child)

func get_difficulty()->float:
	return (log(visited_worlds)/1.4) + 0.3
