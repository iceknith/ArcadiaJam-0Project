extends AnimatedSprite2D

@export var spawnAnimationTime:float = .2
@export var explosionAnimationTime:float = .2

var time:float = .0
var hasExploded:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	animation = "spawn"
	play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	
	if time > spawnAnimationTime && !hasExploded: animation = "fly"
	elif time > explosionAnimationTime && hasExploded: get_parent().queue_free()
	
	if get_parent().direction.x < -0.5:
		flip_h = true
	elif get_parent().direction.x > 0.5:
		flip_h = false
		
func _on_orb_hit():
	hasExploded = true
	animation = "explode"
	time = 0
