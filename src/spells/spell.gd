extends Area2D

class_name Spell

@export var attackPlayer:bool = false
@export var attackEntities:bool = false
@export var costType:String = "gray"
@export var cost:int = 0
@export var damageType:Array = ["yellow","blue","red","gray"]
@export var damageAmount:int = 0
@export var acceleration:float = .0
@export var speed:float = .0
@export var maxDuration:float = .0
@export var autoDisapear:bool = true

signal hit

var duration:float = 0
var direction = Vector2.ZERO
var velocity:Vector2 = Vector2.ZERO
var isAlive:bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	duration += delta
	
	if (duration > maxDuration):
		queue_free()
		
func _physics_process(delta):
	if (isAlive):
		velocity = lerp(velocity, direction * speed, delta * acceleration)
		
		position += velocity * delta

func _on_body_entered(body):
	if ("player" in body.name && attackPlayer):
		var player:Player = body
		player.damage(damageAmount, direction, damageType)
		isAlive = false
		hit.emit()
		if autoDisapear: queue_free()
	elif ("entity" in body.name && attackEntities):
		#do things
		isAlive = false
		hit.emit()
		if autoDisapear: queue_free()
	elif ("TileMap" in body.name):
		isAlive = false
		hit.emit()
		if autoDisapear: queue_free()
