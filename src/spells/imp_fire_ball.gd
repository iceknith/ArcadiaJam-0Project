extends Spell


# Called when the node enters the scene tree for the first time.
func _ready():
	rotation = atan(direction.y/direction.x)
	
	cost = costs_per_level[level]
	maxColorAdd = maxColorAdd_per_level[level]
	acceleration = acceleration_per_leve[level]
	speed = speed_per_level[level]
	maxDuration = maxDuration_per_level[level]

