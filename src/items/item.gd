extends Area2D
class_name Item

@export var isHeal:bool = false
@export var healType:Array = ["gray","red","yellow","blue"]
@export var healAmount:int = 0
@export var isSpell:bool = false
@export var spellPointer:PackedScene
@export var isShop:bool
@export var items:Array[PackedScene]
@export var itemType:Array[String]

signal choose_new_spell(spellPointer:PackedScene)
signal open_shop(items:Array[PackedScene], itemType:Array[String])

# Called when the node enters the scene tree for the first time.
func _ready():
	if isSpell:
		choose_new_spell.connect(get_parent().get_parent().get_parent()._on_player_choosing_spell)
	elif isShop:
		open_shop.connect(get_parent().get_parent().get_parent()._on_player_open_shop)


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
			choose_new_spell.emit(spellPointer)
			queue_free()
		elif (isShop):
			#choose what items to display, depending on player stats
			open_shop.emit(items, itemType)
			queue_free()
