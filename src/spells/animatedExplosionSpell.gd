extends AnimatedSprite2D

@export var spawnAnimationTime:float = .2
@export var explosionAnimationTime:float = .2
@export var explodeToContact:bool = true

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
	
	"if get_parent().direction.x < -0.5:
		flip_h = true
	elif get_parent().direction.x > 0.5:
		flip_h = false"
		
func _on_hit(bodyType:String, body:Node2D):
	if ((explodeToContact || bodyType == "TileMap") && animation != "spawn"):
		hasExploded = true
		animation = "explode"
		get_parent().isAlive = false
		time = 0
	else:
		get_parent().isAlive = true
