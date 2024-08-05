extends Area2D

@export var slowness:float = 200.0
@export var distance_to_boss:float = 250.0

@export var damage_amount = 10

var boss:Entity
var angle:float = 0

func _ready():
	
	name += "_shield_hitbox"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !is_instance_valid(boss):
		queue_free()
		return
	angle += 2*PI*delta/slowness
	position = distance_to_boss*Vector2(cos(angle), sin(angle)) + boss.position 


func _on_area_entered(area):
	var body:Node2D = area.get_parent()
	if (body as Player):
		var player:Player = body
		player.damage(damage_amount, (player.global_position - boss.global_position).normalized(), ["gray"])
