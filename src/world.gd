extends Node2D

signal playerSignal(signalType:String, signalValues:Array)

# Called when thZe node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func generate_new_dungeon():
	$dungeon.world = 1
	$dungeon.roomCount = 0
	$dungeon.shopCount = 0
	$dungeon.generateNewDungeon()
	$player.gray = $player.maxGray
	$player.healthChange.emit("gray", false, $player.gray)

func nextLevel():
	$dungeon.generateNewDungeon()

func _on_player_death():
	get_parent().get_parent().endGame()

func _on_player_health_change(healthType, maxHealthChange, newValue):
	playerSignal.emit("health_change", [healthType, maxHealthChange, newValue])

func _on_player_spell_change(spellNum, newSpell, newSpellType, newSpellCost):
	playerSignal.emit("spell_change", [spellNum, newSpell, newSpellType, newSpellCost])

func _on_player_passive_change(passive, passive_level):
	playerSignal.emit("passive_change", [passive, passive_level])

func _on_player_choosing_spell(spellPointer):
	playerSignal.emit("choosing_spell", [spellPointer])
	(func(): process_mode = Node.PROCESS_MODE_DISABLED).call_deferred()

func _on_player_open_shop(items:Array[PackedScene], itemType:Array[String], itemLevels:Array[int]):
	playerSignal.emit("open_shop", [items, itemType, itemLevels])
	(func(): process_mode = Node.PROCESS_MODE_DISABLED).call_deferred()

func _on_gui_toggle_pause_game():
	if (process_mode == Node.PROCESS_MODE_DISABLED):
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED


func _on_gui_gui_signal(signalType, signalValues):
	if (signalType == "generate_dungeon"):
		generate_new_dungeon()
	elif (signalType == "spell_change"):
		$player.replaceSpell(signalValues[0], signalValues[1], signalValues[2])
	elif (signalType == "gain_item"):
		$player.heal(signalValues[2], signalValues[0])
	elif (signalType == "gain_passive"):
		$player.addPassive(signalValues[0], signalValues[1])

