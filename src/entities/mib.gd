extends Entity

var reload_initial_color:Color = Color(.75, .0, .0)
var reload_end_color:Color = Color(.039, .204, .349)
var reload_color:Color

var reload_circle_hidden:bool = false

func _draw():
	if (state == "dead"): return
	if (!canShoot):
		var shootCooldown = $hit_hitbox/fire_point/shootCooldown
		var reload_progress:float = (shootCooldown.wait_time - shootCooldown.time_left)/shootCooldown.wait_time
		
		reload_color = Color(reload_initial_color.r * (1 - reload_progress) + reload_end_color.r * reload_progress,
							reload_initial_color.g * (1 - reload_progress) + reload_end_color.g * reload_progress,
							reload_initial_color.b * (1 - reload_progress) + reload_end_color.b * reload_progress,
							.9)
	else: reload_color = reload_end_color
	
	draw_circle($hit_hitbox/reloadAnimationPos.position, 15, reload_color)

func _process(delta):
	if (state == "death" && !reload_circle_hidden):
		reload_circle_hidden = true
		queue_redraw()
	super._process(delta)
	
	if (target != null && !canShoot): queue_redraw()
