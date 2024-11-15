extends CharacterBody2D
class_name Entity

signal death
signal rotate

@export var minSpeed = 750.0
@export var acceleration = 50.0
@export var knockbackSpeed = 750.0
@export var minHealth = 100.0
@export var damageToKill:int = 100
@export var meleDamageType:Array = ["gray","blue","yellow","red"]
@export var minMeleDamageAmount:int = 0
@export var ranged:bool = false
@export var shootRange:float = 1000
@export var minShootDamageAmount:int = 0
@export var attacks:Array[PackedScene]
@export var rotatedOffsetX:float = 0

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
var ray_cast

var speed:float
var health:int
var meleDamageAmount:int
var shootDamageAmount:int
var target:CharacterBody2D
var state:String = "idle"
var direction:Vector2 = Vector2.ZERO
var canShoot:bool = true
var wantToMove:bool = true

var popup_text = preload("res://src/popup_text.tscn")

func _ready():
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	health = minHealth
	speed = minSpeed
	meleDamageAmount = minMeleDamageAmount
	shootDamageAmount = minShootDamageAmount
	
	if ($hit_hitbox.get_node_or_null("fire_point")):
		ray_cast = $hit_hitbox/fire_point/RayCast2D as RayCast2D
	
		if (!ranged):
			$hit_hitbox/fire_point.queue_free()

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

func _physics_process(delta):
	if ((state != "hit" && !wantToMove) || state == "dead" || state == "freeze" || state == "cast" || state == "tp"): return
	
	if (state != "hit"):
		direction = to_local(nav_agent.get_next_path_position()).normalized()
		
		movement_handler(direction, delta)
	
	move_and_slide()

func make_path():
	if (state == "dead"): return
	if (target != null):
		nav_agent.target_position = target.position

func action_handler():
	if (state == "dead"): return
	if (ranged && (state == "idle" || state == "walk")):
		if (target != null):
			wantToMove = true
			ray_cast.look_at(target.global_position)
			var collider = ray_cast.get_collider() as Node2D
			if (collider != null && "player" in collider.name):
				wantToMove = false
				if (canShoot): shoot()

func shoot():
	$hit_hitbox/fire_point/shootCooldown.start()
	canShoot = false
	var attack:Spell = attacks.pick_random().instantiate()
	attack.direction = Vector2(cos(ray_cast.rotation), sin(ray_cast.rotation))
	attack.position = $hit_hitbox/fire_point.position + position
	attack.damageAmount = shootDamageAmount
	get_parent().add_child(attack)

func movement_handler(dir:Vector2, delta):
	velocity = lerp(velocity, dir * speed, delta * acceleration)
	
	if dir.distance_squared_to(Vector2.ZERO) <= 0.5:
		$AnimatedSprite2D.animation = "idle"
		state = "idle"
	else:
		$AnimatedSprite2D.animation = "walk"
		state = "walk"

	if dir.x < -0.5 && $AnimatedSprite2D.flip_h:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.offset.x -= rotatedOffsetX
		rotate.emit()
	elif dir.x > 0.5 && !$AnimatedSprite2D.flip_h:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.offset.x += rotatedOffsetX
		rotate.emit()

func damage(damage_amount:int, damage_direction:Vector2):
	if (state == "hit" || state == "invincible" || state == "dead" || target == null): return
	
	health -= damage_amount
	state = "hit"
	velocity = damage_direction * knockbackSpeed
	$AnimatedSprite2D.animation = "hit"
	$invincibilityTimer.start()
	if (ranged):
		$hit_hitbox/fire_point/shootCooldown.stop()
		canShoot = false
	spawn_text_popup("red", str("- ", damage_amount), 2.0, 500)

func spawn_text_popup(textColor:String, textContent:String, textDuration:float, y_margin:float):
	var popup_text_instance:PopupText = popup_text.instantiate()
	popup_text_instance.textColor = textColor
	popup_text_instance.text = textContent
	popup_text_instance.duration = textDuration	
	popup_text_instance.position = position + Vector2.UP*y_margin
	get_parent().add_child(popup_text_instance)

func _on_path_refresh_timer_timeout():
	make_path()

func _on_player_in_same_room(player:Player):
	target = player
	if (ranged):
		canShoot = false
		$hit_hitbox/fire_point/shootCooldown.start()

func _on_hitbox_area_collision(area):
	if (state == "dead" || state == "hit" || state == "invincible"): return
	
	var body:Node2D = area.get_parent()
	if ("player" in body.name):
		var player:Player = body
		player.damage(meleDamageAmount, direction, meleDamageType)

func _on_invincibility_timer_timeout():
	if (state == "hit" || state == "invincible"):
		state = "idle"
		if (ranged):
			$hit_hitbox/fire_point/shootCooldown.start()

func _on_death_animation_timer_timeout():
	queue_free()

func _on_shoot_cooldown_timeout():
	canShoot = true

func _on_freeze_timer_timeout():
	state = "idle"
	if (ranged):
		$hit_hitbox/fire_point/shootCooldown.start()
