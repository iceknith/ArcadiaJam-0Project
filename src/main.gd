extends Node

var game = preload("res://src/game.tscn")
var main_menu = preload("res://src/main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var main_menu_instance = main_menu.instantiate()
	add_child(main_menu.instantiate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta):
	pass

func launchGame():
	get_node("main_menu").queue_free()
	add_child(game.instantiate())
	
func endGame():
	get_node("game").queue_free()
	var main_menu_instance = main_menu.instantiate()
	main_menu_instance.start_game.connect(launchGame)
	add_child(main_menu.instantiate())
