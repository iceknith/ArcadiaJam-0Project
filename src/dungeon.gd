extends Node2D

var rooms:Array = [];
var corridors:Array = [];
var walls:Array = []
var finishRooms:Array = []
var grid:Array = [];

var roomCount:int
var shopCount:int

@export var default_room_cnt:int = 5
@export var max_try_to_spawn_room:int = 5
@export var max_room_to_corridor = 1

var world = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	var file = DirAccess.open("res://src/rooms/")
	
	var i = 1;
	var world_dir = str("world",i)
	while file.dir_exists(world_dir):
		rooms.append([])
		corridors.append([])
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
			elif "finishRoom" in room: 
				finishRooms[i-1].append(load(str("res://src/rooms/world",i,"/",room)) as PackedScene)
			else:
				rooms[i-1].append(load(str("res://src/rooms/world",i,"/",room)) as PackedScene)
		
		i+=1;
		world_dir = str("world",i)
		
	generateNewDungeon.call_deferred()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func generateDungeon(worldNum:int, roomNum:int):
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
	
	var prevRoom:Room = null

	var room_to_corridor = max_room_to_corridor
	var i:int = 0
	
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
		else:
			possible_rooms = rooms_used.duplicate()
		possible_rooms.shuffle()
		
		#Search for a valid room to insert in this space
		while !found_room && possible_rooms.size() > 0:
			
			room = possible_rooms.pop_front().instantiate()
			room.position = current_pix
			if (room.hasMobs):
				room.get_node("spawner").level = worldNum
				room.get_node("spawner").difficulty = get_difficulty(roomCount, shopCount)
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
			var try_to_spawn_room_cnt = max_try_to_spawn_room
			
			while !found_room && try_to_spawn_room_cnt > 0:
				var room_index:int = randi_range(0, grid.size()-1)
				room = grid[room_index]
				current_pos = previous_pos[room_index]
				current_pix = room.position
				possible_dirs = room.entries_dir.duplicate()
				found_room = true;
				
				if (possible_dirs.size() == 0):
						try_to_spawn_room_cnt -= 1
						found_room = false;
						continue;
				current_dir = possible_dirs.pop_front()
				while (intersectsWithRoom(current_pos + current_dir[1], previous_pos)):
					if (possible_dirs.size() == 0):
						found_room = false;
						break;
					current_dir = possible_dirs.pop_front()
				
				if (!found_room):
					try_to_spawn_room_cnt -= 1				
			
			#If we weren't able to find a suitable position
			if (try_to_spawn_room_cnt <= 0):
				push_error("Dungeon Generation Failed !")
				return
			
			#If we did find a position, we update all the variables
			current_pix += current_dir[0]
			current_pos += current_dir[1]
			previous_dir = current_dir
			prevRoom = room
			i -= 1
			room_to_corridor = 0
			continue
			
		#Adding the room
		if (prevRoom != null): 
			prevRoom.door_to_close.append(previous_dir)
			prevRoom.entries_dir.erase(previous_dir)
		#changing the room counts
		if (room.hasMobs and !room.isCorridor): roomCount+=1
		elif (!room.isCorridor): shopCount+=1
		room.walls = walls[worldNum]
		grid.append(room)
		previous_pos.append(current_pos);
		current_pix += current_dir[0]
		current_pos += current_dir[1]
		previous_dir = current_dir
		prevRoom = room
		if (i == 1):
			get_parent().get_node("player").position = position + room.position + room.get_node("LootPosition").position
			room.remove_entities.call_deferred()
		
		if(!room.isCorridor): room_to_corridor -= 1
		else: room_to_corridor = max_room_to_corridor
	
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
		if position.x - room.x == 0 && position.y - room.y == 0: return true
	return false

func generateNewDungeon():
	deleteDungeon()
	generateDungeon(world, default_room_cnt)
	world = world%rooms.size() + 1
	
func deleteDungeon():
	grid = []
	for child in get_children():
		if !("ParallaxBackground" in child.name):
			remove_child(child)

func get_difficulty(roomCount:int, shopCount:int)->float:
	return clamp((roomCount + 5*shopCount)/100, 0, 1)
