extends Spell

@export var explosion_radius:float = 150.0

func _on_hit(bodyType, body):
	$CollisionShape2D.shape.radius = explosion_radius


func _on_area_entered(area):
	var body:Node2D = area.get_parent()
	if ("player" in body.name && attackPlayer):
		var player:Player = body
		player.damage(damageAmount, direction, damageType)
		if (player.gray <= 0): kill.emit()
		hit.emit("player", player)
		if autoDisapear: 
			queue_free()
			
	elif ("hit_hitbox" in area.name && attackEntities):
		var entity:Entity = body
		entity.damage(damageAmount, direction)
		if (entity.health <= 0): kill.emit()
		hit.emit("entity", entity)
		if autoDisapear: 
			queue_free()
