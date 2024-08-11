extends Room

func _init():
	is_boss_room = true

func _ready():
	super._ready()
	room_mobs.append($"hell CEO")

func _process(delta):
	pass
	

func _on_hell_ceo_death():
	dungeon_finished(player)

func _on_player_entered_first_time(player):
	doorClosed = true
	close_doors()
