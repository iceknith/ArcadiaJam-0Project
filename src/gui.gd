extends CanvasLayer

signal generateNewDungeon;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	generateNewDungeon.emit()


func _on_world_player_signal(signalType, signalValues):
	if (signalType == "death"):
		print("Player died")
	elif (signalType == "health_change"):
		$playerGUI.health_change(signalValues[0], signalValues[1], signalValues[2])
	elif (signalType == "spell_change"):
		$playerGUI.spell_change(signalValues[0], signalValues[1], signalValues[2])
