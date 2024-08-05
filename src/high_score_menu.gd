extends Control

@export var score_per_page:int = 3

var high_scores:Array[Array] = []
var index:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	high_scores = get_high_score()
	load_score_page(high_scores, index)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func load_score_page(hs:Array[Array], i:int):
	if (i%score_per_page != 0):
		push_error("Invalid index ! It should be a multiple of " + str(score_per_page))
		return
	
	for node:Control in [$Score1, $Score2, $Score3]:
		if (i >= hs.size()): 
			node.visible = false
			continue
		
		var score:Array = hs[i]
		node.visible = true
		node.get_node("Position").text = str(i + 1)
		node.get_node("Name").text = score[0]
		node.get_node("Score").text = score[1]
		
		i += 1

func get_high_score()->Array[Array]:
	var file = FileAccess.open("res://highscores/hs.txt", FileAccess.READ)
	var data = file.get_as_text()
	file.close()
	
	data = data.split("\n")
	var hs:Array[Array] = []
	for line in data:
		var score:PackedStringArray = line.split(";")
		
		if (score.size() != 4): 
			if (score.size() != 0): push_warning("Invalid high score file ! Deletting the faulty line, which is: ", score)
			continue
		
		hs.append([score[0], score[1] + "-" + score[2] + "-" + score[3]])
		
	return hs


func _on_button_left_pressed():
	index -= score_per_page
	load_score_page(high_scores, index)
	
	#handle buttons
	$button_right.disabled = false
	if (index - score_per_page < 0):
		$button_left.disabled = true

func _on_button_right_pressed():
	index += score_per_page
	load_score_page(high_scores, index)
	
	#handle buttons
	$button_left.disabled = false
	if (index + score_per_page >= high_scores.size()):
		$button_right.disabled = true

func _on_back_pressed():
	get_parent().add_child(load("res://src/main_menu.tscn").instantiate())
	queue_free()
