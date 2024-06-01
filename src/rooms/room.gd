extends Area2D
class_name Room

signal player_entered_first_time(player:Player)

@export var num_entries:int = 4
@export var isCorridor:bool = false

var playerEntered:bool = false
var collisionRect:Rect2;
var entries_dir:Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	collisionRect = $CollisionShape2D.get_shape().get_rect();
	
	num_entries = min(4, max(0, num_entries))
	for i:int in range(num_entries):
		if (get_node_or_null(str("entry",i+1)) == null):
			push_error(str("entry",i+1,". Missing from room object"))
		else:
			entries_dir.append([])
			entries_dir[i].append(2*get_node(str("entry",i+1)).position)
			
			if (abs(entries_dir[i][0].x/collisionRect.size.x) == 1):
				entries_dir[i].append(Vector2(entries_dir[i][0].x/collisionRect.size.x, 0))
			else:
				entries_dir[i].append(Vector2(0, entries_dir[i][0].y/collisionRect.size.y))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	print(self.name," -> ",body.name)
	if ("player" in body.name && !playerEntered):
		playerEntered = true
		var player:Player = body
		player_entered_first_time.emit(player)

