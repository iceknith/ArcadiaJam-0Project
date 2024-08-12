extends Node

var game = preload("res://src/game.tscn")
var main_menu = preload("res://src/main_menu.tscn")
var death_menu = preload("res://src/death_menu.tscn")
var firstLaunch = true

# Called when the node enters the scene tree for the first time.
func _ready():
	var main_menu_instance = main_menu.instantiate()
	add_child(main_menu.instantiate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta):
	pass

func launchGame():
	for child in get_children(): child.queue_free()
	add_child(game.instantiate())
	
	get_node("game").get_node("world").showTutorial = true
	
func endGame():
	firstLaunch = false
	get_node("game").queue_free()
	var death_menu_instance = death_menu.instantiate()
	add_child(death_menu.instantiate())


func gen_dungeon():
	get_node("game").get_node("world").nextLevel()
