extends Control

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready():
	start_game.connect(get_parent().launchGame)

func _on_button_pressed():
	start_game.emit()


func _on_button_2_pressed():
	get_tree().quit()
