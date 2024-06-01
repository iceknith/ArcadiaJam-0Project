extends Node2D

var rooms:Array = [];
var corridors:Array = [];
var grid:Array = [];

@export var default_room_cnt:int = 5
@export var max_try_to_spawn_room:int = 5
@export var max_room_to_corridor = 1

var wallUp
var wallDown
var wallLeft
var wallRight

# Called when the node enters the scene tree for the first time.
func _ready():
	var file = DirAccess.open("res://src/rooms/")
	
	var i = 1;
	var world_dir = str("world",i)
	while file.dir_exists(world_dir):
		rooms.append([])
		corridors.append([])
		
		var world_file = DirAccess.open(str("res://src/rooms/world",i))
		
		for room in world_file.get_files():
			if "corridor" in room:
				corridors[i-1].append(load(str("res://src/rooms/world",i,"/",room)))
			elif "wallLeft" in room: wallLeft = load(str("res://src/rooms/world",i,"/",room))
			elif "wallRight" in room: wallRight = load(str("res://src/rooms/world",i,"/",room))
			elif "wallDown" in room: wallDown = load(str("res://src/rooms/world",i,"/",room))
			elif "wallUp" in room: wallUp = load(str("res://src/rooms/world",i,"/",room))
			else:
				rooms[i-1].append(load(str("res://src/rooms/world",i,"/",room)))
		
		i+=1;
		world_dir = str("world",i)
		
	generateDungeon(1, default_room_cnt)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func generateDungeon(worldNum:int, roomNum:int):
	worldNum -= 1
	
	if worldNum > rooms.size():
		push_error("Invalid World num")
	
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
		if (room_to_corridor == 0):
			possible_rooms = corridor_used.duplicate()
		else:
			possible_rooms = rooms_used.duplicate()
		possible_rooms.shuffle()
		
		#Search for a valid room to insert in this space
		while !found_room && possible_rooms.size() > 0:
		
			room = possible_rooms.pop_front().instantiate()
			room.position = current_pix
			add_child(room)
			
			possible_dirs = room.entries_dir.duplicate()
			
			possible_dirs.shuffle()
			#searching to see if the room connects to an existing room
			for dirs in possible_dirs:
				if dirs[1] == -previous_dir[1]:
					found_room = true
					if (i != 1): room.entries_dir.erase(dirs)
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
			prevRoom.entries_dir.erase(previous_dir)
		grid.append(room)
		previous_pos.append(current_pos);
		current_pix += current_dir[0]
		current_pos += current_dir[1]
		previous_dir = current_dir
		prevRoom = room
		
		if(!room.isCorridor): room_to_corridor -= 1
		else: room_to_corridor = max_room_to_corridor
	
	#close rooms
	for room:Room in grid:
		for direction in room.entries_dir:
			var wall:Node2D
			if direction[1].x == 1:
				wall = wallRight.instantiate()
			elif direction[1].x == -1:
				wall = wallLeft.instantiate()
			elif direction[1].y == -1:
				wall = wallUp.instantiate()
			elif direction[1].y == 1:
				wall = wallDown.instantiate()
				
			wall.position = room.position + direction[0]/2
			add_child(wall)

func intersectsWithRoom(position:Vector2, rooms_pos:Array)->bool:
	for room in rooms_pos:
		if position.x - room.x == 0 && position.y - room.y == 0: return true
	return false

func generateNewDungeon():
	deleteDungeon()
	generateDungeon(1, default_room_cnt)
	
func deleteDungeon():
	grid = []
	for child in get_children():
		remove_child(child)
