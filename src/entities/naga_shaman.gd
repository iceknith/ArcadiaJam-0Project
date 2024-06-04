extends Entity

func action_handler():
	if (state == "dead"): return
	if (ranged && (state == "idle" || state == "walk")):
		if (target != null):
			if (canShoot): shoot()
			wantToMove = true
			ray_cast.look_at(target.global_position)
			var collider = ray_cast.get_collider() as Node2D
			if (collider != null && "player" in collider.name):
				wantToMove = false
