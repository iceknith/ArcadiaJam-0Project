extends CharacterBody2D
class_name  Player

signal healthChange(healthType:String, maxHealthChange:bool, newValue:int)
signal spellChange(spellNum:int, newSpell:String, newSpellType:String, newSpellCost:int)
signal passiveChange(passive:String, passive_level:int)
signal death
signal showTutorial(tutorialType:String)

@export var defaultSpeed = 2000.0
@export var defaultAcceleration = 50.0
@export var defaultKnockbackForce = 1500.0
@export var defaultInvincibilityTimer = 2.0
@export var defaultDashCost = 12
@export var defaultDashSpeed = 4000.0
@export var defaultDashAcceleration = 200.0
@export var defaultDashDuration = 1.0
@export var defaultStabCost = 5
@export var defaultMaxGray = 100
var speed
var acceleration
var knockbackForce
var invincibilityTimer
var dashCost
var dashSpeed
var dashAcceleration
var dashDuration
var stabCost
var damageMultiplier = 1

var additionalStabDamage:int = 0
var stabLifeLeechAmount:int = 0

var maxRed:int = 0
var red:int = 0
var maxBlue:int = 0
var blue:int = 0
var maxYellow:int = 0
var yellow:int = 0
var maxGray:int
var gray:int = 100

var spells:Array[PackedScene] = [null, null, null, null]
var spell_levels:Array[int] = [0, 0, 0, 0]
var passives:Array[String] = []
var passive_levels:Array[int] = []

var firstExistance:bool = false
var firstSpell:bool = false
var firstSpellCasted:bool = false
var firstLowHealth:bool = false
var firstAttackMob:bool = false

var state:String = "idle"
var is_buffed:bool = false
var time_since_state_change:float = 0
var spell_selected:int
var spell_spawned:bool

var stab = preload("res://src/spells/stab.tscn")
var popup_text = preload("res://src/popup_text.tscn")

var direction:Vector2
var buffer_direction:Vector2

func _ready():
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	
	speed = defaultSpeed
	acceleration = defaultAcceleration
	knockbackForce = defaultKnockbackForce
	invincibilityTimer = defaultInvincibilityTimer
	dashCost = defaultDashCost
	dashSpeed = defaultDashSpeed
	dashAcceleration = defaultDashAcceleration
	dashDuration = defaultDashDuration
	stabCost = defaultStabCost
	maxGray = defaultMaxGray

func _process(delta):
	if (state == "dead"): 
		return dead_handler(delta)
	
	#collect actions
	action_handler()
	
	#consequences
	if (gray <= 0 and state != "dead"):
		state = "dead"
	elif (!firstLowHealth && gray <= 50):
		firstLowHealth = true
		showTutorial.emit("lowHealth")
		
	if (!firstExistance):
		firstExistance = true
		showTutorial.emit("intro")
		
	if (state == "stab"): stab_handler(delta)
	elif (state == "spell"): spell_handler(buffer_direction, delta)
	elif (state == "dash" || state == "dash_stop"): dash_handler(delta)
	elif (state == "hit" || state == "invincible"): hit_handler(delta)

func _physics_process(delta):
	if (state == "dead"): return
	
	direction = get_run_input()
	
	if (direction != Vector2.ZERO): buffer_direction = direction
	
	var input:Vector2
	if (state == "stab" || state == "spell"): input = Vector2.ZERO
	else: input = direction
	
	if (state != "hit"):
		movement(input, delta)
	
	move_and_slide()
	
func action_handler():
	if (state == "idle" || state == "walk" || state == "invincible"):
		#dash
		if (Input.is_action_just_pressed("dash")):
			if (gray >= dashCost):
				state = "dash"
				time_since_state_change = 0
				gray -= dashCost
				healthChange.emit("gray", false, gray)
				spawn_text_popup("gray", str("- ", dashCost), 2, 500)
				return
		
		#stab
		if (Input.is_action_just_pressed("stab")):
			if (gray >= stabCost):
				state = "stab"
				spell_spawned = false
				time_since_state_change = 0
				gray -= stabCost
				healthChange.emit("gray", false, gray)
				spawn_text_popup("gray", str("- ", stabCost), 2, 500)
				return
		
		#spells
		var spellList = ["spellUp", "spellLeft", "spellDown", "spellRight"]
		for i in 4:
			if (Input.is_action_just_pressed(spellList[i]) && spells[i] != null):
				var spell:Spell = spells[i].instantiate()
				var canSpawn = false
				var cost = spell.costs_per_level[spell_levels[i]]
				
				if spell.costType == "gray" && gray >= cost:
					canSpawn = true
					gray -= cost
					spawn_text_popup("gray", str("- ", cost), 2, 500)
					healthChange.emit("gray", false, gray)
				elif spell.costType == "red" && red >= cost:
					canSpawn = true
					red -= cost
					spawn_text_popup("red", str("- ", cost), 2, 500)					
					healthChange.emit("red", false, red)
				elif spell.costType == "yellow" && yellow >= cost:
					canSpawn = true
					yellow -= cost
					spawn_text_popup("yellow", str("- ", cost), 2, 500)
					healthChange.emit("yellow", false, yellow)
				elif spell.costType == "blue" && blue >= cost:
					canSpawn = true
					blue -= cost
					spawn_text_popup("blue", str("- ", cost), 2, 500)
					healthChange.emit("blue", false, blue)
					
				if canSpawn:
					buffer_direction = Vector2.ZERO
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
	
	if (state == "idle" || state == "walk"):
		if input.distance_squared_to(Vector2.ZERO) <= 0.5:
			if is_buffed: $AnimatedSprite2D.animation = "idle_buffed"
			else: $AnimatedSprite2D.animation = "idle"
			state = "idle"
		else:
			if is_buffed: $AnimatedSprite2D.animation = "walk_buffed"
			else: $AnimatedSprite2D.animation = "walk"
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
		var dir:Vector2 = Vector2.ZERO
		if $AnimatedSprite2D.flip_h: dir.x = -1
		else: dir.x = 1
		stab_instance.position = position
		stab_instance.direction = dir
		stab_instance.kill.connect(_on_stab_kill)
		if ($AnimatedSprite2D.flip_h):
			stab_instance.position.x -= stab_instance.get_node("CollisionShape2D").get_shape().get_rect().size.x
		get_parent().add_child(stab_instance)
		stab_instance.damageAmount += additionalStabDamage
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
	if (!firstSpellCasted):
		firstSpellCasted = true
		showTutorial.emit("spell_use")
	
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
		spell_instance.position = position
		spell_instance.player = self
		spell_instance.level = spell_levels[spell_selected]
		get_parent().add_child(spell_instance)
		spell_instance.damageAmount *= damageMultiplier
		spell_spawned = true

func hit_handler(delta):
	time_since_state_change += delta
	if (state == "hit"):
		$AnimatedSprite2D.animation = "hit"
		if (time_since_state_change > 0.666):
			state = "invincible"
			time_since_state_change = 0
	elif (state == "invincible"):
		$AnimatedSprite2D.animation = "invincible"
		if (time_since_state_change > invincibilityTimer):
			state = "idle"

func dead_handler(delta):
	$AnimatedSprite2D.animation = "dead"
	time_since_state_change += delta
	if (time_since_state_change >= 2):
		death.emit()

func damage(damage_amount:int, damage_direction:Vector2, damageType:Array):
	if (state == "dash" || state == "hit" || state == "invincible"): return
	
	state = "hit"
	velocity = knockbackForce * damage_direction
	time_since_state_change = 0
	var y_popup_margin = 500
	
	if (damage_amount > 0 && "red" in damageType && red > 0):
		var damage_red = min(damage_amount, red)
		red -= damage_red
		damage_amount -= damage_red
		spawn_text_popup("red", str("- ", damage_red), 2, y_popup_margin)
		y_popup_margin -= 100
		healthChange.emit("red", false, red)
		
	if (damage_amount > 0 && "yellow" in damageType && yellow > 0):
		var damage_yellow = min(damage_amount, yellow)
		yellow -= damage_yellow
		damage_amount -= damage_yellow
		spawn_text_popup("yellow", str("- ", damage_yellow), 2, y_popup_margin)
		y_popup_margin -= 100
		healthChange.emit("yellow", false, yellow)		
		
	if (damage_amount > 0 && "blue" in damageType && blue > 0):
		var damage_blue = min(damage_amount, blue)
		blue -= damage_blue
		damage_amount -= damage_blue
		spawn_text_popup("blue", str("- ", damage_blue), 2, y_popup_margin)
		y_popup_margin -= 100
		healthChange.emit("blue", false, blue)		
		
	if (damage_amount > 0 && gray > 0):
		var damage_gray = min(damage_amount, gray)
		gray -= damage_gray
		damage_amount -= damage_gray
		spawn_text_popup("gray", str("- ", damage_gray), 2, y_popup_margin)
		healthChange.emit("gray", false, gray)		

func heal(heal_amount:int, heal_type:Array):
	var y_popup_margin = 500
	if ("gray" in heal_type):
		gray = min(maxGray, gray + heal_amount)
		spawn_text_popup("gray", str("+ ", heal_amount), 2, y_popup_margin)
		y_popup_margin -= 100
		healthChange.emit("gray", false, gray)
	if ("red" in heal_type):
		red = min(maxRed, red + heal_amount)
		spawn_text_popup("red", str("+ ", heal_amount), 2, y_popup_margin)
		y_popup_margin -= 100
		healthChange.emit("red", false, red)
	if ("yellow" in heal_type):
		yellow = min(maxYellow, yellow + heal_amount)
		spawn_text_popup("yellow", str("+ ", heal_amount), 2, y_popup_margin)
		y_popup_margin -= 100
		healthChange.emit("yellow", false, yellow)
	if ("blue" in heal_type):
		blue = min(maxBlue, blue + heal_amount)
		spawn_text_popup("blue", str("+ ", heal_amount), 2, y_popup_margin)
		healthChange.emit("blue", false, blue)

func replaceSpell(spell_num:int, new_spell:PackedScene, new_spell_level:int):
	if (!firstSpell):
		firstSpell = true
		showTutorial.emit("spell")
	
	#update max-life
	if (spells[spell_num - 1] != null):
		var oldSpell:Spell = spells[spell_num - 1].instantiate()
		var oldSpellLevel:int = spell_levels[spell_num - 1]
		if (oldSpell.costType == "gray"):
			maxGray -= oldSpell.maxColorAdd_per_level[oldSpellLevel]
			healthChange.emit("gray", true, maxGray)
			gray = min(maxGray, gray)
			healthChange.emit("gray", false, gray)
		if (oldSpell.costType == "red"):
			maxRed -= oldSpell.maxColorAdd_per_level[oldSpellLevel]
			healthChange.emit("red", true, maxRed)
			red = min(maxRed, red)
			healthChange.emit("red", false, red)
		if (oldSpell.costType == "yellow"):
			maxYellow -= oldSpell.maxColorAdd_per_level[oldSpellLevel]
			healthChange.emit("yellow", true, maxYellow)
			yellow = min(maxYellow, yellow)
			healthChange.emit("yellow", false, yellow)
		if (oldSpell.costType == "blue"):
			maxBlue -= oldSpell.maxColorAdd_per_level[oldSpellLevel]
			healthChange.emit("blue", true, maxBlue)
			blue = min(maxBlue, blue)
			healthChange.emit("blue", false, blue)
	spells[spell_num - 1] = new_spell
	spell_levels[spell_num - 1] = new_spell_level
	var spell:Spell = new_spell.instantiate()
	spellChange.emit(spell_num, spell.name, spell.costType, spell.costs_per_level[new_spell_level])
	if (spell.costType == "gray"):
		maxGray += spell.maxColorAdd_per_level[new_spell_level]
		healthChange.emit("gray", true, maxGray)
		gray += spell.maxColorAdd_per_level[new_spell_level]
		healthChange.emit("gray", false, gray)
	if (spell.costType == "red"):
		maxRed += spell.maxColorAdd_per_level[new_spell_level]
		healthChange.emit("red", true, maxRed)
		red += spell.maxColorAdd_per_level[new_spell_level]
		healthChange.emit("red", false, red)
	if (spell.costType == "yellow"):
		maxYellow += spell.maxColorAdd_per_level[new_spell_level]
		healthChange.emit("yellow", true, maxYellow)
		yellow += spell.maxColorAdd_per_level[new_spell_level]
		healthChange.emit("yellow", false, yellow)
	if (spell.costType == "blue"):
		maxBlue += spell.maxColorAdd_per_level[new_spell_level]
		healthChange.emit("blue", true, maxBlue)
		blue += spell.maxColorAdd_per_level[new_spell_level]
		healthChange.emit("blue", false, blue)

func addPassive(passiveName:String, passiveLevel:int):
	
	if (passiveName == "Passive Regenation"):
		$RegenerationTimer.stop()
		if passiveLevel == 0: $RegenerationTimer.wait_time = 5
		elif passiveLevel == 1: $RegenerationTimer.wait_time = 3
		elif passiveLevel == 2: $RegenerationTimer.wait_time = 2.5
		elif passiveLevel == 3: $RegenerationTimer.wait_time = 1.5
		$RegenerationTimer.start()
		
	elif (passiveName == "Max Gray"):
		if passiveLevel == 0: maxGray = defaultMaxGray + 30
		elif passiveLevel == 1: maxGray = defaultMaxGray + 70
		elif passiveLevel == 2: maxGray = defaultMaxGray + 100
		elif passiveLevel == 3: maxGray = defaultMaxGray + 130
		healthChange.emit("gray", true, maxGray)
		
	elif (passiveName == "Stab Cost"):
		if passiveLevel == 0: stabCost = defaultStabCost - 1
		elif passiveLevel == 1: stabCost = defaultStabCost - 2
		elif passiveLevel == 2: stabCost = defaultStabCost - 4
		elif passiveLevel == 3: stabCost = defaultStabCost - 5
		
	elif (passiveName == "Dash Cost"):
		if passiveLevel == 0: dashCost = defaultDashCost - 1
		elif passiveLevel == 1: dashCost = defaultDashCost - 2
		elif passiveLevel == 2: dashCost = defaultDashCost - 4
		elif passiveLevel == 3: dashCost = defaultDashCost - 5
		
	elif (passiveName == "Dash Duration"):
		if passiveLevel == 0: dashDuration = defaultDashDuration * 0.1
		elif passiveLevel == 1: dashDuration = defaultDashDuration * 0.25
		elif passiveLevel == 2: dashDuration = defaultDashDuration * 0.45
		elif passiveLevel == 3: dashDuration = defaultDashDuration * 0.6
		
	elif (passiveName == "Speed"):
		if passiveLevel == 0: speed = defaultSpeed * 1.05
		elif passiveLevel == 1: speed = defaultSpeed * 1.1
		elif passiveLevel == 2: speed = defaultSpeed * 1.2
		elif passiveLevel == 3: speed = defaultSpeed * 1.3
		
	elif (passiveName == "Life Leech"):
		if passiveLevel == 0: stabLifeLeechAmount = 8
		elif passiveLevel == 1: stabLifeLeechAmount = 15 
		elif passiveLevel == 2: stabLifeLeechAmount = 20
		elif passiveLevel == 3: stabLifeLeechAmount = 25
		
	elif (passiveName == "Stab Damage"):
		if passiveLevel == 0: additionalStabDamage = 3
		elif passiveLevel == 1: additionalStabDamage = 5
		elif passiveLevel == 2: additionalStabDamage = 8
		elif passiveLevel == 3: additionalStabDamage = 10
		
	passiveChange.emit(passiveName, passiveLevel)
	if (passiveName in passives):
		passive_levels[passives.find(passiveName)] = passiveLevel
	else:
		passives.append(passiveName)
		passive_levels.append(passiveLevel)

func spawn_text_popup(textColor:String, textContent:String, textDuration:float, y_margin:float):
	var popup_text_instance:PopupText = popup_text.instantiate()
	popup_text_instance.textColor = textColor
	popup_text_instance.text = textContent
	popup_text_instance.duration = textDuration	
	popup_text_instance.position = position + Vector2.UP*y_margin
	get_parent().add_child(popup_text_instance)

func _on_regeneration_timer_timeout():
	var prevGray = gray
	gray = min(gray+3, maxGray)
	if prevGray != gray:
		spawn_text_popup("gray", "+ 1", 0.25, 500)
		healthChange.emit("gray", false, gray)

func _on_stab_kill():
	var prevGray = gray
	gray = min(gray+stabLifeLeechAmount, maxGray)
	if prevGray != gray:
		spawn_text_popup("gray", str("+ ", stabLifeLeechAmount), 1, 500)
		healthChange.emit("gray", false, gray)
