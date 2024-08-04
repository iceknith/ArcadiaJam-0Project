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
var damageHealed:int = 0 #describes the amount of damage the player should be able to inflict thanks to the heal provided by the room
var healPercent = 0

var player:Player
var playerEntered:bool = false
var doorClosed:bool = false
var collisionRect:Rect2;
var entries_dir:Array = []
var door_to_close:Array = []
var walls:Array = []
var openDoorTimer = 0

var room_mobs:Array[Entity] = []


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
		player.damage_emitted = 0
		player_entered_first_time.emit(player)
		playerEntered = true
		player.room_mobs = room_mobs
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
		damageHealed = min(damageHealed, player.damage_emitted * healPercent) #have the player be rewarded for using less damage than anticipated
		player.room_mobs = []
		var lootStat = player_get_heal()
		var lootItem:Item = loot[lootStat[0]].instantiate()
		lootItem.healTypes = lootStat[1]
		lootItem.healAmounts = lootStat[2]
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

func player_get_heal()->Array:
	if player == null:
		push_error("ERROR: Attempt to spawn heal without player")
		
		
	var colors = ["gray", "red", "yellow", "blue"]
	colors.shuffle()
	var damage_per_color:Dictionary = get_damage_per_color(player)
	var heal_per_color:Dictionary = {"gray":0, "red":0, "yellow":0, "blue":0}
	var damageToHeal:int = damageHealed
	var result:Array = [0, [], []]
	
	var maxColor = "gray"
	var maxHeal = 0
	#If the player really needs to be healed gray
	if (player.gray < player.maxGray/2):
		result[1].append("gray")
		result[2].append((int) (min(player.maxGray - player.gray, damageToHeal/damage_per_color["gray"])))
		damageToHeal -= result[2][-1] * damage_per_color["gray"]
		maxHeal = result[2][-1]
		colors.remove_at(0)
	
	for c in colors:
		#Check if we have to exit
		if (damageToHeal <= 0): break
		
		if player.get_color(c) < player.get_max_color(c) && damage_per_color[c]:
			result[1].append(c)
			result[2].append((int) (min(player.get_max_color(c) - player.get_color(c), damageToHeal/damage_per_color[c])))
			heal_per_color[c] += result[2][-1]
			damageToHeal -= result[2][-1] * damage_per_color[c]
			
			if result[2][-1] > maxHeal:
				maxColor = c
				maxHeal = result[2][-1]
			
	result[0] = ["gray", "red", "yellow", "blue"].find(maxColor)
	
	return result

func get_damage_per_color(player:Player)->Dictionary:
	var spells:Array[PackedScene] = player.spells.duplicate()
	spells.append(player.stab)
	var spell_levels:Array[int] = player.spell_levels.duplicate()
	spell_levels.append(0)
	
	var colorSpells:Dictionary = {"gray":0, "red":0, "yellow":0, "blue":0}
	var colorDamage:Dictionary ={"gray":.0, "red":.0, "yellow":.0, "blue":.0}
	var colors:Array[String] = ["gray", "red", "yellow", "blue"]
	
	for i in range(spells.size()):
		if spells[i] == null: continue
		var spell:Spell = spells[i].instantiate()
		var spell_level:int = spell_levels[i]
		for c in colors:
			if c == spell.costType:
				colorDamage[c] += (float) (spell.damageAmount_per_level[spell_level]) / spell.costs_per_level[spell_level]
				colorSpells[c] += 1
				break
		spell.queue_free()
		
	for c in colors:
		if colorSpells[c]:
			colorDamage[c] /= colorSpells[c]
	return colorDamage

func _on_finish_timer_timeout():
	for body in get_overlapping_bodies():
		if ("player" in body.name):
			get_parent().get_parent().nextLevel.call_deferred()
	playerEntered = false
