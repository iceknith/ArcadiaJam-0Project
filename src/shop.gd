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
var colorLabel:Dictionary = {"red":"rouge", "yellow":"jaune", "blue":"bleu", "gray":"gris"}
var spell_info_text:Dictionary = {
	"Orbe enflammé" : ["Un projectile rapide qui explose à l'impact.",""],
	"Lame sanguinaire" : ["Une lame de feu qui traverse les ennemis, gagnant en taille à chaque amélioration.",""],
	"Quadruple taillade" : ["Projette quatre lames en cône qui disparaissent au contact.","x4"],
	"Lame laser" : ["Une lame magique qui attaque les ennemis proches en quart de cercle.",""],
	"Bourrasque" : ["Ce sort économe vous permettera de projeter vos ennemis à l'autre bout de la pièce.",""],
	"Lame scintillante" : ["Une entaille de petite taille qui inflige de lourds dégâts.",""],
	"Flèches givrées" : ["Lance quatre flèches en croix paralysant les ennemis au contact.","x4"],
	"Orbe explosif" : ["Une boule d'énergie infligeant des dégâts de zone à distance.",""],
	"Grenade à fragmentation" : ["Un projectile lent qui explose après un certain temps.",""],
	"Papillons" : ["Disperse une myriade de petits projectiles en cercles.","x12"],
	"Default" : ["Ce sort valide vos CS à votre place",""]
}
var passive_info_text:Dictionary = {
	
	"Esprit renforcé" : ["Augmente la taille de votre jauge d'essence.","Essence max","+30","+50","+70","+100"],
	"Couteau économe" : ["Attaquer au couteau consomme moins d'essence.","Consommation","-1","-2","-4","-5"],
	"Dash économe" : ["Bondir consomme moins d'énergie.","Consommation","-1","-2","-4","-5"], 
	"Grand bond" : ["Le bond gagne en portée et en vitesse.","Statistiques","+10%","+25%","+45%","+60%"],
	"Marathon" : ["Augmente votre vitesse de course.","Vitesse","+20%","+30%","+40%","+50%"],
	"Vol d'esprit" : ["Régénère de l'essence après chaque meutre au couteau.","Régénération","8","12","15","18"],
	"Lame pointue" : ["Votre couteau inflige plus de dégats.","Dégâts","+3","+5","+8","+10"],
	"Default" : ["Confère un boost de motivation pendant la semaine d'exams","Caféine","+100%"]
}

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
	$item_1/select_button.was_active = false
	$spell_1_button.was_active = true
	
	for i in 3:
		var marker:Marker2D = get_node(str("item_", i+1))
		if (i < itemIconPath.size()):
			marker.visible = true
			marker.get_node("select_button").visible = true
			marker.get_node("icon").visible = true
			marker.get_node("icon").texture = load(itemIconPath[i])
			if (itemType[i] == "item"):
				var item:Item = itemPointers[i].instantiate()
				marker.get_node("description").text = str("Heal de\n+ ", item.healAmount, " ", item.healType[0])
		
			elif ("spell" in itemType[i]):
				var spell:Spell = itemPointers[i].instantiate()
				spell.level = itemLevels[i]
				var name:String = str(spell.name, " ", levelLabel[spell.level])
				var atk:String = str(spell.damageAmount_per_level[spell.level])
				var cost:String = str(spell.costs_per_level[spell.level])
				var max:String = str(spell.maxColorAdd_per_level[spell.level])
				var color:String = colorLabel[spell.costType]
				var text = spell_info_text.get(spell.name)
				if (text == null):
					text = spell_info_text["Default"]
				marker.get_node("description").text =  "{name}\n\n{text}\n\nCouleur : {color}\nDégats : {atk} {atkmodifier}\nConsommation : {cost}\nEssence max : +{max}".format({"name":name,"text":text[0],"color":color,"atk":atk,"cost":cost,"atkmodifier":text[1],"max":max})
				
			elif ("passive_" in itemType[i]):
				var name:String = str(itemType[i].split("_")[1], " ", levelLabel[itemLevels[i]])
				var text = passive_info_text.get(itemType[i].split("_")[1])[0]
				var stat = passive_info_text.get(itemType[i].split("_")[1])[1]
				var statmodifier = passive_info_text.get(itemType[i].split("_")[1])[itemLevels[i]+2]
				if (text == null): 
					text = passive_info_text["Default"][0]
					stat = passive_info_text["Default"][1]
					statmodifier = passive_info_text["Default"][2]
				marker.get_node("description").text = "{name}\n\n{text}\n\n{stat} : {statmodifier}".format({"name":name,"text":text,"stat":stat,"statmodifier":statmodifier})
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
	$spell_1_button.was_active = false
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
