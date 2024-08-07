extends Spell

@export var rotation_slowness:float = 10.0
@export var distance_from_point:float = 800 

var max_rotation:float = PI
var rotation_point:Vector2
var rotation_around_point:float = 0
var initial_pos:float = PI/4
var blade_rotation_add:float = PI
var parent:Entity
var rotation_sense:int

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	rotation_sense = 1 if randi_range(0, 1) == 0 else -1
	
	initial_pos = direction.angle() - rotation_sense * PI/4
	rotation_around_point = initial_pos
	
	if 7*PI/6 > direction.angle() and direction.angle() > 5*PI/6:
		blade_rotation_add = 0
		$AnimatedSprite2D.flip_h = true
	
	global_position = rotation_point + Vector2(cos(rotation_around_point), sin(rotation_around_point)) * distance_from_point
	rotation = rotation_around_point+blade_rotation_add

func _on_area_exited(area):
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation_around_point += rotation_sense * 2*PI*delta/rotation_slowness
	#print(rotation_around_point, initial_pos + rotation_sense * max_rotation)
	
	# offset using the rotation
	global_position = parent.global_position + Vector2(cos(rotation_around_point), sin(rotation_around_point)) * distance_from_point
	rotation = rotation_around_point+blade_rotation_add
	
	if rotation_sense == -1 && rotation_around_point <= initial_pos - max_rotation:
		queue_free()
	elif rotation_sense ==  1 && rotation_around_point >= initial_pos + max_rotation:
		queue_free()


func custom_queue_free():
	queue_free()
