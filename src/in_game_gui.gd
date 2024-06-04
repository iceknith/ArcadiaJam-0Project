extends CanvasLayer

signal togglePauseGame
signal GUISignal(signalType:String, signalValues:Array)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Shop.visible = false
	$playerGUI.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta):
	pass

func _on_button_pressed():
	GUISignal.emit("generate_dungeon", [])

func _on_world_player_signal(signalType, signalValues):
	if (signalType == "death"):
		print("Player died")
	elif (signalType == "health_change"):
		$playerGUI.health_change(signalValues[0], signalValues[1], signalValues[2])
	elif (signalType == "spell_change"):
		$playerGUI.spell_change(signalValues[0], signalValues[1], signalValues[2], signalValues[3])
	elif (signalType == "passive_change"):
		$playerGUI.passive_change(signalValues[0], signalValues[1])
	elif (signalType == "choosing_spell"):
		var spell:Spell = signalValues[0].instantiate()
		var spellIconPath:String = str("res://assets/spells/", spell.name, "/icon.png")
		$Shop.visible = true
		$Shop.init_item_selection([spellIconPath], [signalValues[0]], ["spell"])
	elif (signalType == "open_shop"):
		var iconPath:Array[String] = []
		for i in signalValues[0].size():
			if "spell" in signalValues[1][i]:
				var buyable = signalValues[0][i].instantiate()
				iconPath.append(str("res://assets/spells/",buyable.name, "/icon.png"))
			elif signalValues[1][i] == "item":
				var buyable = signalValues[0][i].instantiate()
				iconPath.append(str("res://assets/items/",buyable.name, "/icon.png"))
			elif ("passive_" in signalValues[1][i]):
				iconPath.append("res://assets/passives/icon.png")
		$Shop.visible = true
		$Shop.init_item_selection(iconPath, signalValues[0], signalValues[1], signalValues[2])


func _on_shop_dialogue_end():
	$Shop.visible = false
	togglePauseGame.emit()
	

func _on_shop_player_gain_spell(spell_num:int, spellPointer:PackedScene, spell_level:int):
	GUISignal.emit("spell_change", [spell_num, spellPointer, spell_level])


func _on_shop_player_gain_item(health_type, is_max_health, change):
	GUISignal.emit("gain_item", [health_type, is_max_health, change])

func _on_shop_player_gain_passive(passive_name, passive_level):
	GUISignal.emit("gain_passive", [passive_name, passive_level])
