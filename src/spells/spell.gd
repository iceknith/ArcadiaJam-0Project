extends Area2D

class_name Spell

@export var utilitySpell:bool
@export var attackPlayer:bool = false
@export var attackEntities:bool = false
@export var costType:String = "gray"
@export var maxLevels:int = 0
@export var maxColorAdd_per_level:Array[int] = [0]
@export var costs_per_level:Array[int] = [0]
@export var damageAmount_per_level:Array[int] = [0]
@export var acceleration_per_leve:Array[float] = [.0]
@export var speed_per_level:Array[float] = [.0]
@export var maxDuration_per_level:Array[float] = [.0]
@export var damageType:Array = ["yellow","blue","red","gray"]
@export var autoDisapear:bool = false
@export var deleted_by_map:bool = true

signal hit(bodyType:String, body:Node2D)
signal kill

var level:int = 0
var cost
var maxColorAdd
var damageAmount
var acceleration
var speed
var maxDuration

var player:Player
var duration:float = 0
var direction = Vector2.ZERO
var velocity:Vector2 = Vector2.ZERO
var isAlive:bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	rotation = -atan2(-direction.y,direction.x)
	
	cost = costs_per_level[level]
	maxColorAdd = maxColorAdd_per_level[level]
	damageAmount = damageAmount_per_level[level]
	acceleration = acceleration_per_leve[level]
	speed = speed_per_level[level]
	maxDuration = maxDuration_per_level[level]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (utilitySpell): return
	
	duration += delta
	
	if (duration > maxDuration):
		queue_free()

func _on_body_entered(body):
	if ("TileMap" in body.name && deleted_by_map):
		isAlive = false
		hit.emit("TileMap", body)
		if autoDisapear: queue_free()

func _physics_process(delta):
	if (isAlive):
		velocity = lerp(velocity, direction * speed, delta * acceleration)
		
		position += velocity * delta

func _on_area_exited(area):
	if ("room" in area.name || "Room" in area.name || "corridor" in area.name):
		isAlive = false
		hit.emit("TileMap", area)
		if autoDisapear: 
			queue_free()

func _on_area_entered(area):
	var body:Node2D = area.get_parent()
	if (!isAlive): return
	if ("player" in body.name && attackPlayer):
		var player:Player = body
		player.damage(damageAmount, direction, damageType)
		if (player.gray <= 0): kill.emit()
		hit.emit("player", player)
		if autoDisapear: 
			queue_free()
			
	elif ("hit_hitbox" in area.name && attackEntities && body.state != "dead"):
		var entity:Entity = body
		entity.damage(damageAmount, direction)
		if (entity.health <= 0): kill.emit()
		hit.emit("entity", entity)
		if autoDisapear: 
			queue_free()
