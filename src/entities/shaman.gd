extends Entity

@export var push_back_force:float = 2.0

func _draw():
	if (state != "dead"): draw_circle(Vector2.ZERO, 700, Color(.7, .0, .0, .3))

func _on_attack_hitbox_area_entered(area):
	if (state == "dead" || state == "hit" || state == "invincible"): return
	
	var body:Node2D = area.get_parent()
	if ("player" in body.name):
		var player:Player = body
		var damage_direction:Vector2 = (player.global_position - global_position).normalized() * push_back_force
		player.damage(meleDamageAmount, damage_direction, meleDamageType)

func _process(delta):
	if (state == "dead"): return
	
	#collect actions
	action_handler()
	
	#consequences
	if (health <= 0 and state != "dead"):
		state = "dead"
		$AnimatedSprite2D.animation = "dead"
		$deathAnimationTimer.start()
		if ($hit_hitbox.get_node_or_null("Shadow")): $hit_hitbox.get_node("Shadow").visible = false
		velocity = Vector2.ZERO
		death.emit()
		queue_redraw()
