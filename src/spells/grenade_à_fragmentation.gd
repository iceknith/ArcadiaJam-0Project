extends Spell

@export var explosion_radius:float = 300.0

var time:float = .0
var hasExploded:bool = false

func _ready():
	super._ready()
	
	$AnimatedSprite2D.animation = "spawn"
	$AnimatedSprite2D.play()

func _process(delta):
	time += delta
	
	if time > 0.333 && !hasExploded: $AnimatedSprite2D.animation = "fly"
	elif time > 0.25 && hasExploded: queue_free()
	
	if direction.x < -0.5:
		$AnimatedSprite2D.flip_h = true
	elif direction.x > 0.5:
		$AnimatedSprite2D.flip_h = false

func _on_hit(bodyType, body):
	isAlive = true

func _on_timer_timeout():
	$CollisionShape2D.shape.radius = explosion_radius
	hasExploded = true
	$AnimatedSprite2D.animation = "explode"
	time = 0
