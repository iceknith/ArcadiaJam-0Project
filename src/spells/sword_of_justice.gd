extends Spell

var hasHitEntity:bool
var entities:Array[Entity]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	super._physics_process(delta)
	
	if (hasHitEntity):
		for entity in entities:
			if (entity || entity.state == "dead"): continue
			
			entity.velocity = Vector2.ZERO
			entity.position += velocity * delta
			entity.move_and_slide()


func _on_hit(bodyType, body):
	if (bodyType == "entity"):
		hasHitEntity = true
		entities.append(body)
		isAlive = true
	elif (bodyType == "TileMap"):
		isAlive = false
		queue_free()
