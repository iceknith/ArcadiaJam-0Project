extends Area2D
class_name Item

@export var isHeal:bool = false
@export var healType:Array = ["gray","red","yellow","blue"]
@export var healAmount:int = 0
@export var isSpell:bool = false
@export var spellPointer:PackedScene
@export var isShop:bool

var spells:Array[PackedScene] = [load("res://src/spells/fire_ball.tscn"),
								load("res://src/spells/blood_blade.tscn"),
								load("res://src/spells/cutting_frenzy.tscn"),
								load("res://src/spells/cutting_freak.tscn"),
								load("res://src/spells/quadruple_slash.tscn"),
								load("res://src/spells/wind_burst.tscn"),
								load("res://src/spells/speed_burst.tscn"),
								load("res://src/spells/dash_burst.tscn"),
								load("res://src/spells/sword_of_justice.tscn"),
								load("res://src/spells/frozen_arrow.tscn"),
								load("res://src/spells/fire_orb.tscn"),
								load("res://src/spells/butterflies.tscn"),
								load("res://src/spells/grenade_à_fragmentation.tscn"),
								load("res://src/spells/attack_burst.tscn"),
								load("res://src/spells/the_world.tscn")]
var passives:Array[String] = ["Passive Regenation", "Max Gray", "Stab Cost", "Dash Cost", 
							"Dash Duration", "Speed", "Life Leech", "Stab Damage"]

signal choose_new_spell(spellPointer:PackedScene)
signal open_shop(items:Array[PackedScene], itemType:Array[String], itemLevels:Array[int])

# Called when the node enters the scene tree for the first time.
func _ready():
	if isSpell:
		choose_new_spell.connect(get_parent().get_parent().get_parent()._on_player_choosing_spell)
	elif isShop:
		open_shop.connect(get_parent().get_parent().get_parent()._on_player_open_shop)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body:Node2D):
	if ("player" in body.name):
		var player:Player = body
		if (isHeal):
			player.heal(healAmount, healType)
			queue_free()
		elif (isSpell):
			choose_new_spell.emit(spellPointer)
			queue_free()
		elif (isShop):
			shop_handler(player)
			queue_free()

func shop_handler(player:Player):
	var items:Array[PackedScene] = []
	var itemLevels:Array[int] = []
	var itemType:Array[String] = []
	
	var player_can_upgrade_spells = false
	for i in player.spells.size(): 
		if player.spells[i] != null && player.spell_levels[i] < 3: 
			player_can_upgrade_spells = true
			break
			
	var player_can_upgrade_passive = false
	if (player.passives.is_empty()): player_can_upgrade_passive = false
	else:
		print(player.passives)
		for level in player.passive_levels:
			if level < 3:
				player_can_upgrade_passive = true
				break
			
	#first item
	if (randi_range(1, 2) == 1):
		items.append(spells.pick_random())
		itemLevels.append(0)
		itemType.append("spell")
	else:
		items.append(null)
		itemLevels.append(0)
		itemType.append(str("passive_", passives.pick_random()))
	
	#second item
	if player_can_upgrade_passive:
		var indexes:Array = range(player.passives.size())
		indexes.shuffle()
		for i in indexes:
			if (player.passive_levels[i] < 3):
				items.append(null)
				itemLevels.append(player.passive_levels[i] + 1)
				itemType.append(str("passive_", player.passives[i]))
				break
	else:
		items.append(null)
		itemLevels.append(0)
		itemType.append(str("passive_", passives.pick_random()))
			
	#third item
	if (player_can_upgrade_spells):
		var indexes:Array = range(4)
		indexes.shuffle()
		for i in indexes:
			if (player.spells[i] != null && player.spell_levels[i] < 3):
				items.append(player.spells[i])
				itemLevels.append(player.spell_levels[i] + 1)
				itemType.append(str("spellUpgrade_",i+1))
				break
	else:
		items.append(spells.pick_random())
		itemLevels.append(0)
		itemType.append("spell")
		
	
	#choose what items to display, depending on player stats
	open_shop.emit(items, itemType, itemLevels)
