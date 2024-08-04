extends Control

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready():
	start_game.connect(get_parent().launchGame)


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta):
	pass


func _on_button_pressed():
	start_game.emit()


func _on_high_scores_button_pressed():
	get_parent().add_child(load("res://src/high_score_menu.tscn").instantiate())
	queue_free()


func _on_quit_pressed():
	get_tree().quit()
