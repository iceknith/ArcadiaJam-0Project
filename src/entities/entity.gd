extends CharacterBody2D
class_name Entity

signal death

@export var speed = 300.0
@export var acceleration = 50.0
@export var maxHealth = 100.0
@export var ranged:bool = false
@export var attacks:Array[PackedScene]
@export var maxChaseDistance:float = 500

var target:CharacterBody2D
var health = maxHealth
var maxChaseDistanceSquared = pow(maxChaseDistance, 2)
var state:String = "idle"
var direction:Vector2 = Vector2.ZERO

func _ready():
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()

func _process(delta):
	
	#collect actions
	action_handler()
	
	#collisions
	
	#consequences
	if (health <= 0 and state != "dead"):
		state = "dead"
		death.emit()

func _physics_process(delta):
	direction = to_local($NavigationAgent2D.get_next_path_position()).normalized()
	
	movement_handler(direction, delta)

func make_path():
	if (target != null && position.distance_squared_to(target.position) <= maxChaseDistanceSquared):
		$NavigationAgent2D.target_position = target.global_position

func action_handler():
	pass

func movement_handler(dir:Vector2, delta):
	velocity = lerp(velocity, dir * speed, delta * acceleration)
	
	if dir.distance_squared_to(Vector2.ZERO) <= 0.5:
		$AnimatedSprite2D.animation = "idle"
		state = "idle"
	else:
		$AnimatedSprite2D.animation = "walk"
		state = "walk"

	if dir.x < -0.5:
		$AnimatedSprite2D.flip_h = true
	elif dir.x > 0.5:
		$AnimatedSprite2D.flip_h = false

func damage(damage_amount:int, damage_direction:Vector2):
	health -= damage_amount

func _on_path_refresh_timer_timeout():
	make_path()

func _on_player_in_same_room(player:Player):
	target = player
