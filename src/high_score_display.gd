extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = get_high_score_string()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_high_score_string()->String:
	var file = FileAccess.open("res://highscores/hs.txt", FileAccess.READ)
	var data = file.get_as_text()
	file.close()
	
	data = data.split("\n")
	var result:String = ""
	var i:int = 0
	for line in data:
		var score:PackedStringArray = line.split(";")
		
		if (score.size() != 4): 
			if (score.size() != 0): push_warning("Invalid high score file ! Deletting the faulty line, which is: ", score)
			continue
		
		result = result + score[0] + " - Loop " + score[1] + " World " + score[2] + " Room " + score[3] +  "\n"
		i += 1
		
	return result
