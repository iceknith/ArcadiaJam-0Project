extends Area2D

@export var isHeal:bool = false
@export var healType:Array = ["gray","red","yellow","blue"]
@export var healAmount:int = 0
@export var isSpell:bool = false
@export var spellPointer:PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body:Node2D):
	if ("player" in body.name):
		var player:Player = body
		if (isHeal):
			player.heal(healAmount, healType)
			queue_free()
		elif (isSpell):
			print("Make player select spell")
			
			#temporary
			player.replaceSpell(1, spellPointer)
			queue_free()
