extends Spell

@export var size_per_levels:Array[float] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	scale = size_per_levels[level] * Vector2.ONE
