extends Node2D

signal playerSignal(signalType:String, signalValues:Array)

@export var max_high_score_saved = 15
var showTutorial:bool = false
var high_scores:Array[Array] = []

var player_room_count:int = 0
var player_world_count:int = 0
var player_loop_count:int = 1

# Called when thZe node enters the scene tree for the first time.
func _ready():
	high_scores = load_high_scores()
	nextLevel.call_deferred()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func nextLevel():
	$dungeon.generateNewDungeon($player)
	player_loop_count += player_world_count/$dungeon.rooms.size()
	player_world_count = (player_world_count%$dungeon.rooms.size()) + 1
	player_room_count = 1
	
func load_high_scores()->Array[Array]:
	var hs:Array[Array] = []
	
	var file = FileAccess.open("res://highscores/hs.txt", FileAccess.READ)
	var data = file.get_as_text()
	file.close()
	
	data = data.split("\n")
	var i:int = 0
	for line in data:
		hs.append(line.split(";") as Array) 
		
		if (hs[i].size() != 4): 
			if (hs[i].size() != 0): push_warning("Invalid high score file ! Deletting the faulty line, which is: ", hs[i])
			hs.remove_at(i)
			continue
		
		for j in range(1, 4): hs[i][j] = (int) (hs[i][j])
		i += 1
	
	return hs

func register_new_score(hs:Array[Array], loopCnt:int, worldCnt:int, roomCnt:int)->bool:
	return high_scores.size() < max_high_score_saved || compare_high_score(["temp", loopCnt, worldCnt, roomCnt], hs[hs.size() - 1])
	
func compare_high_score(hs1:Array, hs2:Array)->bool:
	var score1:int = hs1[1] * 1000 + hs1[2] * 100 + hs1[3]
	var score2:int = hs2[1] * 1000 + hs2[2] * 100 + hs2[3]
	return score1 > score2

func save_high_scores(hs:Array[Array], name:String, loopCnt:int, worldCnt:int, roomCnt:int):
	hs.append([name, loopCnt, worldCnt, roomCnt])
	hs.sort_custom(compare_high_score)
	var data:String = ""
	for i in range(0, min(hs.size(), max_high_score_saved)):
		data = data + ";".join(hs[i] as PackedStringArray) + "\n"

	var file = FileAccess.open("res://highscores/hs.txt", FileAccess.WRITE)
	file.store_string(data)
	file.close()

func _on_player_death():
	if (register_new_score(high_scores, player_loop_count, player_world_count, player_room_count)):
		$player.queue_free()
		$dungeon.queue_free()
		$CanvasModulate.queue_free()
		playerSignal.emit("hide gui", [])
		$highScoreRegister/Label2.text = $highScoreRegister/Label2.text.replace("X", str(player_loop_count))
		$highScoreRegister/Label2.text = $highScoreRegister/Label2.text.replace("Y", str(player_world_count))
		$highScoreRegister/Label2.text = $highScoreRegister/Label2.text.replace("Z", str(player_room_count))
		$highScoreRegister.show()
	else:
		get_parent().get_parent().endGame()

func _on_player_health_change(healthType, maxHealthChange, newValue):
	playerSignal.emit("health_change", [healthType, maxHealthChange, newValue])

func _on_player_spell_change(spellNum, newSpell, newSpellType, newSpellCost, newSpellLevel):
	playerSignal.emit("spell_change", [spellNum, newSpell, newSpellType, newSpellCost, newSpellLevel])

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
	if (signalType == "spell_change"):
		$player.replaceSpell(signalValues[0], signalValues[1], signalValues[2])
	elif (signalType == "gain_item"):
		$player.heal(signalValues[2], signalValues[0])
	elif (signalType == "gain_passive"):
		$player.addPassive(signalValues[0], signalValues[1])

func _on_player_show_tutorial(tutorialType):
	if (showTutorial):
		playerSignal.emit("showTutorial", [tutorialType])

func _on_dungeon_player_entered_room():
	player_room_count += 1

func _on_text_edit_name_found(name):
	save_high_scores(high_scores, name.replace("\n",""), player_loop_count, player_world_count, player_room_count)
	get_parent().get_parent().endGame()
