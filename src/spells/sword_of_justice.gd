extends Spell

var hasHitEntity:bool
var entities:Array[Entity]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	super._physics_process(delta)
	
	if (hasHitEntity and !is_queued_for_deletion()):
		for entity in entities:
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
