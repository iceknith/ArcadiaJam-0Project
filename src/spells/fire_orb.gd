extends Spell

@export var explosion_radius:float = 300.0

func _on_hit(bodyType, body):
	$CollisionShape2D.shape.radius = explosion_radius
