extends Entity


func _on_hitbox_area_collision(area):
	if (state == "dead" || state == "hit" || state == "invincible"): return
	
	var body:Node2D = area.get_parent()
	if ("player" in body.name):
		var player:Player = body
		var damagedPlayer:bool = false
		if ("red" in meleDamageType && player.red > 0):
			player.damage(max(1,player.red*meleDamageAmount/100), direction, ["red"])
			damagedPlayer = true
		if ("yellow" in meleDamageType && player.yellow > 0):
			player.damage(max(1,player.yellow*meleDamageAmount/100), direction, ["yellow"])
			damagedPlayer = true
		if ("blue" in meleDamageType && player.blue > 0):
			player.damage(max(1,player.blue*meleDamageAmount/100), direction, ["blue"])
			damagedPlayer = true
		if ((!damagedPlayer || "gray" in meleDamageType) && player.gray > 0):
			player.damage(max(1,player.gray*meleDamageAmount/100), direction, ["gray"])
			damagedPlayer = true
