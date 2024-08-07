extends Entity

const IDLE_STATE:String = "idle"
const WALK_STATE:String = "walk"
const HIT_STATE:String = "hit"
const INVINCIBLE_STATE:String = "invincible"
const CASTING_STATE:String = "cast"
const TELEPORTING_STATE:String = "tp"
const DEAD_STATE:String = "dead"

@export var shield:PackedScene
@export var phase_1_health:int = 100
@export var phase_1_speed:int = 500
@export var phase_1_acceleration:float = 25
@export var phase_1_attacks:Array[PackedScene] = []
@export var phase_1_shield_count:int = 2
@export var phase_2_health:int = 100
@export var phase_2_speed:int = 1000
@export var phase_2_acceleration:float = 150
@export var phase_2_attacks:Array[PackedScene] = []
@export var phase_2_shield_count:int = 5
@export var phase_2_min_dist_to_tp:int = 2000
@export var phase_2_tp_distance:float = 1000.0

var phase = 1
var can_cast:bool = true
var can_tp:bool = true
var isCasting:bool = false
var isTPing:bool = false
var shields:Array[Area2D] = []
var casted_spells:Array[Spell] = []

var animation_durations:Dictionary = {"idle":0, "walk":0, "hit":0, "cast":0, "teleport_p2":0, "dead":0}
@onready var sprite_frames:SpriteFrames = $AnimatedSprite2D.sprite_frames

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	state = IDLE_STATE
	health = phase_1_health
	speed = phase_1_speed
	acceleration = phase_1_acceleration
	
	change_default_animations(phase)
	spawn_shields(phase_1_shield_count)
	set_phase_independant_animation_durations()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (!can_act()): return
	
	#collect actions
	action_handler()
	
	#death handler
	if (health <= 0 && state != DEAD_STATE):
		$AnimatedSprite2D.animation = "dead"
		state = DEAD_STATE
		velocity = Vector2.ZERO
		$deathAnimationTimer.wait_time = animation_durations["dead"]
		$deathAnimationTimer.start()
		clear_shields()
		clear_attacks()
		if phase != 1:
			if ($hit_hitbox.get_node_or_null("Shadow")): $hit_hitbox.get_node("Shadow").visible = false
			$deathAnimationTimer.start()

func change_default_animations(phase:int):
	if (not phase in [1, 2]):
		push_error("This boss has only phase 1 & 2 !")
		return
	
	for animation_name:String in ["walk", "idle", "hit", "cast", "dead"]:
		var phase_animation_name:String = animation_name + "_p" + str(phase)
		var animation_duration:int = 0
		for i in range(sprite_frames.get_frame_count(animation_name)): sprite_frames.remove_frame(animation_name, 0  )
		for i in range(sprite_frames.get_frame_count(phase_animation_name)):
			sprite_frames.add_frame(
				animation_name, 
				sprite_frames.get_frame_texture(phase_animation_name, i),
				sprite_frames.get_frame_duration(phase_animation_name, i)
			)
			animation_duration += sprite_frames.get_frame_duration(phase_animation_name, i)
		animation_durations[animation_name] = animation_duration

func set_phase_independant_animation_durations():
	for animation_name:String in ["teleport_p2"]:
		var animation_duration:int = 0
		for i in range(sprite_frames.get_frame_count(animation_name)):
			animation_duration += sprite_frames.get_frame_duration(animation_name, i)
		animation_durations[animation_name] = animation_duration

func action_handler():
	if (!can_act()): return
	
	if (phase == 1):
		if (!can_cast && $castTimeoutTimerP1.is_stopped()):
			$castTimeoutTimerP1.start()
		
		if can_cast:
			state = CASTING_STATE
			isCasting = true
			can_cast = false
			$AnimatedSprite2D.animation = "cast"
			$spellCastTimer.wait_time = animation_durations["cast"]
			$spellCastTimer.start()
	elif (phase == 2):
		if (!can_cast && $castTimeoutTimerP2.is_stopped()):
			$castTimeoutTimerP2.start()
			
		if (!can_tp && $tpTimeoutTimer.is_stopped()):
			$tpTimeoutTimer.start()
			
		if can_cast:
			if (can_tp && global_position.distance_to(target.global_position) >= phase_2_min_dist_to_tp):
				state = TELEPORTING_STATE
				isTPing = true
				can_tp = false
				$AnimatedSprite2D.animation = "teleport_p2"
				$tpTimer.wait_time = animation_durations["teleport_p2"]
				$tpTimer.start()
			else:
				state = CASTING_STATE
				isCasting = true
				can_cast = false
				$AnimatedSprite2D.animation = "cast"
				$spellCastTimer.wait_time = animation_durations["cast"]
				$spellCastTimer.start()

func cast_spell():
	if !is_instance_valid(self) || state == DEAD_STATE: return
	
	var potential_attacks:Array[PackedScene]
	if (phase == 1): potential_attacks = phase_1_attacks
	if (phase == 2): potential_attacks = phase_2_attacks
	var spell:Spell = potential_attacks.pick_random().instantiate()
	spell.direction = (target.global_position - global_position).normalized()
	spell.position = position
	spell.parent = self
	get_parent().add_child(spell)
	casted_spells.append(spell)
	state = IDLE_STATE
	isCasting = false

func spawn_shields(shield_count:int):
	for shield_instance:Area2D in shields: shield_instance.queue_free()
	shields = []
	
	var angle:float = 0
	for i in range(shield_count):
		var new_shield:Area2D = shield.instantiate()
		new_shield.angle = angle
		new_shield.boss = self
		shields.append(new_shield)
		get_parent().add_child.call_deferred(new_shield)
		
		angle += 2*PI/shield_count

func can_act()->bool:
	return target != null && \
		state != INVINCIBLE_STATE && \
		state != DEAD_STATE && \
		state != CASTING_STATE && \
		state != TELEPORTING_STATE

func damage(damage_amount:int, damage_direction:Vector2):
	super.damage(damage_amount, Vector2.ZERO)

func clear_shields():
	for shield in shields:
		if is_instance_valid(shield): shield.queue_free()
	shields = []
	
func clear_attacks():
	for attack in casted_spells:
		if is_instance_valid(casted_spells): attack.custom_queue_free()
	casted_spells = []

func _on_cast_timeout_timer_timeout():
	if !is_instance_valid(self) || state == DEAD_STATE: return
	
	can_cast = true

func _on_invincibility_timer_timeout():
	if !is_instance_valid(self): return
	
	if (state == HIT_STATE || state == INVINCIBLE_STATE):
		if (isCasting): state = CASTING_STATE
		else: state = IDLE_STATE
		if (ranged):
			$hit_hitbox/fire_point/shootCooldown.start()

func _on_death_animation_timer_timeout():
	if (phase == 1):
		phase = 2
		
		state = IDLE_STATE
		health = phase_2_health
		speed = phase_2_speed
		acceleration = phase_2_acceleration
		
		change_default_animations(phase)
		spawn_shields(phase_2_shield_count)
		queue_redraw()
	else:
		death.emit()
		super._on_death_animation_timer_timeout()

func _on_tp_timer_timeout():
	if !is_instance_valid(self) || state == DEAD_STATE: return
	
	global_position = target.global_position - (target.global_position - global_position).normalized() * phase_2_tp_distance
	
	state = IDLE_STATE

func _on_tp_timeout_timer_timeout():
	if !is_instance_valid(self) || state == DEAD_STATE: return
	
	can_tp = true
