extends Area2D

class_name Spell

@export var attackPlayer:bool = false
@export var attackEntities:bool = false
@export var costType:String = "gray"
@export var maxColorAdd:int = 0
@export var cost:int = 0
@export var damageType:Array = ["yellow","blue","red","gray"]
@export var damageAmount:int = 0
@export var acceleration:float = .0
@export var speed:float = .0
@export var maxDuration:float = .0
@export var autoDisapear:bool = true

signal hit
signal kill

var duration:float = 0
var direction = Vector2.ZERO
var velocity:Vector2 = Vector2.ZERO
var isAlive:bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	rotation = atan(direction.y/direction.x)

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
	if ("TileMap" in body.name):
		isAlive = false
		hit.emit()
		if autoDisapear: queue_free()

func _on_area_entered(area):
	var body:Node2D = area.get_parent()
	if ("player" in body.name && attackPlayer):
		var player:Player = body
		player.damage(damageAmount, direction, damageType)
		isAlive = false
		if (player.gray <= 0): kill.emit()
		hit.emit()
		if autoDisapear: queue_free()
	elif ("hit_hitbox" in area.name && attackEntities):
		var entity:Entity = body
		entity.damage(damageAmount, direction)
		isAlive = false
		if (entity.health <= 0): kill.emit()
		hit.emit()
		if autoDisapear: queue_free()
