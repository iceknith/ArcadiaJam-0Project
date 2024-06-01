extends Node2D

signal playerSignal(signalType:String, signalValues:Array)

# Called when thZe node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_gui_generate_new_dungeon():
	$dungeon.generateNewDungeon()
	$player.position = Vector2.ZERO
	$player.gray = $player.maxGray
	$player.healthChange.emit("gray", false, $player.gray)


func _on_player_death():
	playerSignal.emit("death", null)


func _on_player_health_change(healthType, maxHealthChange, newValue):
	playerSignal.emit("health_change", [healthType, maxHealthChange, newValue])


func _on_player_spell_change(spellNum, newSpell, newSpellCost):
	playerSignal.emit("spell_change", [spellNum, newSpell, newSpellCost])
