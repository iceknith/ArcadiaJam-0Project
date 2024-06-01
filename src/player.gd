extends CharacterBody2D
class_name  Player

signal healthChange(healthType:String, maxHealthChange:bool, newValue:int)
signal spellChange(spellNum:int, newSpell:String, newSpellCost:int)
signal death

@export var speed = 300.0
@export var acceleration = 50.0
@export var dashCost = 12
@export var dashSpeed = 600.0
@export var dashAcceleration = 200.0
@export var dashDuration = 1.0
@export var stabCost = 5

var maxRed:int = 100
var red:int = 0
var maxBlue:int = 0
var blue:int = 0
var maxYellow:int = 0
var yellow:int = 0
var maxGray:int = 100
var gray:int = 100

var spells:Array[PackedScene] = [null, null, null, null]

var state:String = "idle"
var time_since_state_change:float = 0
var spell_selected:int
var spell_spawned:bool

var stab = preload("res://src/spells/stab.tscn")

var direction:Vector2

func _ready():
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()

func _process(delta):
	
	#collect actions
	action_handler()
	
	#collisions
	
	#consequences
	if (gray <= 0 and state != "dead"):
		state = "dead"
		death.emit()
		
	if (state == "stab"): stab_handler(delta)
	elif (state == "spell"): spell_handler(direction, delta)
	elif (state == "dash" || state == "dash_stop"): dash_handler(delta)

func _physics_process(delta):
	direction = get_run_input()
	var input:Vector2
	if (state == "stab" || state == "spell"): input = Vector2.ZERO
	else: input = direction
	movement(input, delta)
	
	move_and_slide()
	
func action_handler():
	if (state == "idle" || state == "walk"):
		#dash
		if (Input.is_action_just_pressed("dash")):
			if (gray >= dashCost):
				state = "dash"
				time_since_state_change = 0
				gray -= dashCost
				healthChange.emit("gray", false, gray)
				return
		
		#stab
		if (Input.is_action_just_pressed("stab")):
			if (gray >= stabCost):
				state = "stab"
				spell_spawned = false
				time_since_state_change = 0
				gray -= stabCost
				healthChange.emit("gray", false, gray)
				return
		
		#spells
		var spellList = ["spellUp", "spellLeft", "spellDown", "spellRight"]
		for i in 4:
			if (Input.is_action_just_pressed(spellList[i]) && spells[i] != null):
				var spell:Spell = spells[i].instantiate()
				var canSpawn = false
				
				if spell.costType == "gray" && gray >= spell.cost:
					canSpawn = true
					gray -= spell.cost
					healthChange.emit("gray", false, gray)
				elif spell.costType == "red" && red >= spell.cost:
					canSpawn = true
					red -= spell.cost
					healthChange.emit("red", false, red)
				elif spell.costType == "yellow" && yellow >= spell.cost:
					canSpawn = true
					yellow -= spell.cost
					healthChange.emit("yellow", false, yellow)
				elif spell.costType == "blue" && blue >= spell.cost:
					canSpawn = true
					blue -= spell.cost
					healthChange.emit("blue", false, blue)
					
				if canSpawn:
					state = "spell"
					spell_selected = i
					spell_spawned = false
					time_since_state_change = 0
					return
	
func get_run_input()->Vector2:
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return input.normalized()
	
func movement(input:Vector2, delta):
	if state == "dash":
		velocity = lerp(velocity, input * dashSpeed, delta * dashAcceleration)
	else:
		velocity = lerp(velocity, input * speed, delta * acceleration)
	
	if state == "dash" || state == "dash_stop" || state == "stab" || state == "spell":
		pass
	elif input.distance_squared_to(Vector2.ZERO) <= 0.5:
		$AnimatedSprite2D.animation = "idle"
		state = "idle"
	else:
		$AnimatedSprite2D.animation = "walk"
		state = "walk"

	if input.x < -0.5:
		$AnimatedSprite2D.flip_h = true
	elif input.x > 0.5:
		$AnimatedSprite2D.flip_h = false

func stab_handler(delta):
	$AnimatedSprite2D.animation = "stab"
	time_since_state_change += delta
	if (time_since_state_change >= 0.5):
		state = "idle"
	elif (time_since_state_change > 0.33 && !spell_spawned):
		var stab_instance:Spell = stab.instantiate()
		if ($AnimatedSprite2D.flip_h):
			stab_instance.position.x = -stab_instance.get_node("CollisionShape2D").get_shape().get_rect().size.x
		add_child(stab_instance)
		spell_spawned = true

func dash_handler(delta):
	if state == "dash":
		$AnimatedSprite2D.animation = "dash"
		time_since_state_change += delta
		
		if time_since_state_change > dashDuration:
			time_since_state_change = 0
			state = "dash_stop"
	else:
		$AnimatedSprite2D.animation = "dash_stop"
		time_since_state_change += delta
		if time_since_state_change > 0.2:
			state = "idle"
			time_since_state_change = 0

func spell_handler(input:Vector2, delta):
	$AnimatedSprite2D.animation = "spell"
	time_since_state_change += delta
	if (time_since_state_change >= 0.5):
		state = "idle"
	elif (time_since_state_change > 0.25 && !spell_spawned):
		var spell_instance:Spell = spells[spell_selected].instantiate()
		
		if (input == Vector2.ZERO):
			if $AnimatedSprite2D.flip_h: input.x = -1
			else: input.x = 1
		spell_instance.direction = input
		spell_instance.position = position #change for better spawning points
		get_parent().add_child(spell_instance)
		spell_spawned = true

func damage(damage_amount:int, damage_direction:Vector2, damageType:Array):
	print("Player damaged")
	
func heal(heal_amount:int, heal_type:Array):
	if ("gray" in heal_type):
		gray = min(maxGray, gray + heal_amount)
		healthChange.emit("gray", false, gray)
	if ("red" in heal_type):
		red = min(maxRed, red + heal_amount)
		healthChange.emit("red", false, red)
	if ("yellow" in heal_type):
		yellow = min(maxYellow, yellow + heal_amount)
		healthChange.emit("yellow", false, yellow)
	if ("blue" in heal_type):
		blue = min(maxBlue, blue + heal_amount)
		healthChange.emit("blue", false, blue)
		
func replaceSpell(spell_num:int, new_spell:PackedScene):
	spells[spell_num - 1] = new_spell
	var spellName = new_spell.resource_path.split("/")[-1].split(".")[0]
	spellChange.emit(spell_num, spellName, 10)
