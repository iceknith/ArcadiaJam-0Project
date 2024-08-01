extends Spell

var orb_num:int = 12

func _ready():
	rotation = atan(direction.y/direction.x)
	
	cost = costs_per_level[level]
	maxColorAdd = maxColorAdd_per_level[level]
	acceleration = acceleration_per_leve[level]
	speed = speed_per_level[level]
	maxDuration = maxDuration_per_level[level]
	
	var fire_orbs:PackedScene = load("res://src/spells/naga_fire_orb.tscn")
	var tetha:float = 0
	var new_direction:Vector2 = Vector2(1, 0)
	var theta_step:float = .0
	if (orb_num != 0):
		theta_step = 2*PI/orb_num
		direction = new_direction
		rotation = tetha
	
	for i in orb_num-1:
		tetha += theta_step
		new_direction = Vector2(cos(tetha), sin(tetha))
		var fire_orb:Spell = fire_orbs.instantiate()
		fire_orb.orb_num = 0
		fire_orb.direction = new_direction
		fire_orb.position = position
		fire_orb.damageAmount = damageAmount
		get_parent().add_child(fire_orb)
