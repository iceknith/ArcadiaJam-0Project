extends Spell

var rotation_point:Vector2
var rotation_around_point:float = 0
var initial_pos:float = PI/4
var distance_from_point:float = 800
var blade_rotation_add:float = PI


@export var knock_back_force_multiplier = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()

	
	rotation_point = global_position
	
	initial_pos = direction.angle() + PI/4
	rotation_around_point = initial_pos
	
	if 7*PI/6 > direction.angle() and direction.angle() > 5*PI/6:
		blade_rotation_add = 0
	
	global_position = rotation_point + Vector2(cos(rotation_around_point), sin(rotation_around_point)) * distance_from_point
	rotation = rotation_around_point+blade_rotation_add



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation_around_point -= delta*5
	
	# offset using the rotation
	global_position = rotation_point + Vector2(cos(rotation_around_point), sin(rotation_around_point)) * distance_from_point
	rotation = rotation_around_point+blade_rotation_add
	
	if rotation_around_point < initial_pos-PI/2:
		queue_free()
	
func _on_hit(bodyType, body):
	if (bodyType == "entity"):
		var entity:Entity = body
		entity.velocity *= knock_back_force_multiplier
