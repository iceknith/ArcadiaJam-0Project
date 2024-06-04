extends Spell

@export var knock_back_force_multiplier = 3

func _on_hit(bodyType, body):
	if (bodyType == "entity"):
		var entity:Entity = body
		entity.velocity *= knock_back_force_multiplier
