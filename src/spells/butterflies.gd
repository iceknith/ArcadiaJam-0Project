extends Spell

@export var butterflies_num:int = 12

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	
	var butterflies:PackedScene = load("res://src/spells/butterflies.tscn")
	var tetha:float = 0
	var new_direction:Vector2 = Vector2(1, 0)
	var theta_step:float = 2*PI/butterflies_num
	if (butterflies_num != 0):
		direction = new_direction
		rotation = tetha
	
	for i in butterflies_num-1:
		tetha += theta_step
		new_direction = Vector2(cos(tetha), sin(tetha))
		var butterflies_instance:Spell = butterflies.instantiate()
		butterflies_instance.butterflies_num = 0
		butterflies_instance.direction = new_direction
		butterflies_instance.position = position
		get_parent().add_child(butterflies_instance)
