extends Control

var maxRed:int = 100
var red:int = 0
var maxBlue:int = 0
var blue:int = 0
var maxYellow:int = 0
var yellow:int = 0
var maxGray:int = 100
var gray:int = 100

var grayImages:Array = [preload("res://assets/GUI/hp_bar/gray1.png"),
						preload("res://assets/GUI/hp_bar/gray2.png"),
						preload("res://assets/GUI/hp_bar/gray3.png"),
						preload("res://assets/GUI/hp_bar/gray4.png")]
var redImages:Array = [preload("res://assets/GUI/hp_bar/red1.png"),
						preload("res://assets/GUI/hp_bar//red2.png"),
						preload("res://assets/GUI/hp_bar//red3.png"),
						preload("res://assets/GUI/hp_bar//red4.png")]
var yellowImages:Array = [preload("res://assets/GUI/hp_bar/yellow1.png"),
						preload("res://assets/GUI/hp_bar/yellow2.png"),
						preload("res://assets/GUI/hp_bar/yellow3.png"),
						preload("res://assets/GUI/hp_bar/yellow4.png")]
var blueImages:Array = [preload("res://assets/GUI/hp_bar/blue1.png"),
						preload("res://assets/GUI/hp_bar/blue2.png"),
						preload("res://assets/GUI/hp_bar/blue3.png"),
						preload("res://assets/GUI/hp_bar/blue4.png")]


# Called when the node enters the scene tree for the first time.
func _ready():
	display_health()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func health_change(healthType:String, maxHealthChange:bool, newValue:int):
	if (healthType == "gray"):
		if (maxHealthChange): maxGray = newValue
		else: gray = newValue
	elif (healthType == "red"):
		if (maxHealthChange): maxRed = newValue
		else: red = newValue
	elif (healthType == "yellow"):
		if (maxHealthChange): maxYellow = newValue
		else: yellow = newValue
	elif (healthType == "blue"):
		if (maxHealthChange): maxBlue = newValue
		else: blue = newValue
	else:
		push_error(str("Unvalid health type: ",healthType))
	display_health()
	
func display_health():
	#gray
	if (gray <= 0):
		$health_bar_gray.texture = null
	else:
		$health_bar_gray.texture = grayImages[min(3, int(4*gray/maxGray))]
	$health_counter_gray.text = str(max(0, gray))
	#red
	if (red <= 0):
		$health_bar_red.texture = null
	else:
		$health_bar_red.texture = redImages[min(3, int(4*red/maxRed))]
	$health_counter_red.text = str(max(0, red))
	#yellow
	if (yellow <= 0):
		$health_bar_yellow.texture = null
	else:
		$health_bar_yellow.texture = yellowImages[min(3, int(4*yellow/maxYellow))]
	$health_counter_yellow.text = str(max(0, yellow))
	#blue
	if (blue <= 0):
		$health_bar_blue.texture = null
	else:
		$health_bar_blue.texture = blueImages[min(3, int(4*blue/maxBlue))]
	$health_counter_blue.text = str(max(0, blue))
	
func spell_change(spellNum:int, newSpell:String, newSpellCost:int):
	var pos:Marker2D = get_node(str("spell_", spellNum, "_pos"))
	var spell_icon = load(str("res://assets/spells/",newSpell,"/icon.png"))
	var spell_sprite:Sprite2D = Sprite2D.new()
	spell_sprite.position = pos.position
	spell_sprite.texture = spell_icon
	spell_sprite.scale = Vector2(0.5, 0.5)
	
	add_child(spell_sprite)
