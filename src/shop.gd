extends Control

signal player_gain_item(health_type:Array[String], is_max_health:bool, change:int)
signal player_gain_passive(passive_name:String, passive_level:int)
signal player_gain_spell(spell_num:int, spellPointer:PackedScene, spell_level:int)
signal dialogue_end

var state = "select_item"
var itemPointers:Array
var itemLevels:Array
var selectedItem:PackedScene
var selectedItemLevel:int
var itemTypes:Array

var levelLabel:Array = ["I","II","III","IV"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init_item_selection(itemIconPath:Array, itemPointer:Array, itemType:Array, itemLevel:Array[int]):
	if (itemIconPath.size() != itemType.size() || itemIconPath.size() > 3):
		push_error("Invalid item display args")
		return
		
	itemPointers = itemPointer
	itemLevels = itemLevel
	itemTypes = itemType
	
	for i in 3:
		var marker:Marker2D = get_node(str("item_", i+1))
		if (i < itemIconPath.size()):
			marker.visible = true
			marker.get_node("select_button").visible = true
			marker.get_node("icon").visible = true
			marker.get_node("icon").texture = load(itemIconPath[i])
			if(itemType[i] == "item"):
				var item:Item = itemPointers[i].instantiate()
				marker.get_node("description").text = str("Heal de\n+ ", item.healAmount, " ", item.healType[0])
			elif ("spell" in itemType[i]):
				var spell:Spell = itemPointers[i].instantiate()
				spell.level = itemLevels[i]
				marker.get_node("description").text = str(spell.name, " ", levelLabel[spell.level],
				"\n Essence consommée : ", spell.costs_per_level[spell.level], " ", spell.costType, "\n Essence max : +",
				 spell.maxColorAdd_per_level[spell.level], " ", spell.costType)
			elif ("passive_" in itemType[i]):
				marker.get_node("description").text = str(itemType[i].split("_")[1], " ", levelLabel[itemLevels[i]])
		else:
			marker.visible = false
	
	if (itemIconPath.size() == 1):
		if (itemTypes[0] != "spell"):
			push_error("Invalid item types, shop only works with >1 items or >=1 spell")
			return
		$item_1.get_node("select_button").visible = false
		selectedItem = itemPointers[0]
		state = "select_spell"
		$text_label.text = "Choisissez où ce sort ira !"
	else:
		state = "select_item"
		$text_label.text = "Choisissez un item !"
	
	for i in 4:
		if (itemIconPath.size() == 1):
			get_node(str("spell_", i+1,"_button")).visible = true
		else:
			get_node(str("spell_", i+1,"_button")).visible = false

func init_spell_selection(index:int):
	$text_label.text = "Choisissez où ce sort ira !"
	for i in 3:
		if (i != index):
			get_node(str("item_", i+1)).visible = false
		else:
			get_node(str("item_", i+1)).get_node("select_button").visible = false
	
	for i in 4:
		get_node(str("spell_", i+1,"_button")).visible = true

func select_item(index:int):
	index -= 1
	selectedItem = itemPointers[index]
	selectedItemLevel = itemLevels[index]
	if ("passive_" in itemTypes[index]):
		player_gain_passive.emit(itemTypes[index].split("_")[1], selectedItemLevel)
		dialogue_end.emit()
	elif (itemTypes[index] == "item"):
		var item = selectedItem.instantiate()
		player_gain_item.emit(item.healType, false, item.healAmount)
		dialogue_end.emit()
	elif (itemTypes[index] == "spell"):
		init_spell_selection(index)
	elif ("spellUpgrade_" in itemTypes[index]):
		player_gain_spell.emit(int(itemTypes[index].split("_")[1]), selectedItem, selectedItemLevel)
		dialogue_end.emit()
	
func select_spell(index:int):
	player_gain_spell.emit(index, selectedItem, selectedItemLevel)
	dialogue_end.emit()
	
func _on_select_item_1_button_pressed():
	select_item(1)

func _on_select_item_2_button_pressed():
	select_item(2)

func _on_select_item_3_button_pressed():
	select_item(3)


func _on_spell_1_button_pressed():
	select_spell(1)

func _on_spell_2_button_pressed():
	select_spell(2)

func _on_spell_3_button_pressed():
	select_spell(3)

func _on_spell_4_button_pressed():
	select_spell(4)

func _on_back_button_pressed():
	dialogue_end.emit()
