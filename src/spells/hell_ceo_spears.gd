extends Spell

@export var distance_between_spells:float = 30.0
var is_on_upper_ceiling:bool
var spawn_spells:bool = true
var parent:Entity


# Called when the node enters the scene tree for the first time.
func _ready():
	if !spawn_spells: 
		super._ready()
		return
	
	is_on_upper_ceiling = randi_range(0, 1) == 1
	
	if (is_on_upper_ceiling):
		direction = Vector2.DOWN
	else:
		direction = Vector2.UP
		
	var room_rect:Rect2 = (get_parent().get_node("CollisionShape2D") as CollisionShape2D).shape.get_rect()
	
	position = room_rect.position + (Vector2(0, 500) if is_on_upper_ceiling else Vector2(0, room_rect.size.y - 500))
	super._ready()
	
	#spawn other spells
	for x in range(0, room_rect.size.x, distance_between_spells):
		var new_spell:Spell = load("res://src/spells/hell_ceo_spears.tscn").instantiate()
		new_spell.spawn_spells = false
		new_spell.position = position + Vector2(x, 0)
		new_spell.direction = direction
		get_parent().add_child(new_spell)
		
