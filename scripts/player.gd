class_name Player extends CharacterBody2D

enum PlayerState { IDLE, WALKING, JUMPING, DUCKING, HURTED }

signal player_death()

@onready var explosion_timer: Timer = $ExplosionTimer
@onready var anim = $AnimatedSprite2D
@onready var collisionShape = $CollisionShape2D
@onready var hitBox = $Hitbox/CollisionShape2D
@onready var jump_effect: AudioStreamPlayer2D = $SoundEffects/JumpEffect
@onready var second_jump_effect: AudioStreamPlayer2D = $SoundEffects/SecondJumpEffect
@onready var water_effect: AudioStreamPlayer2D = $SoundEffects/WaterEffect

@export var max_speed = 300.0
@export var deceleration = 1200.0
@export var acceleration = 1600.0
@export var start_jump_velocity = 600
@export var jump_velocity_increment = 10.0
@export var second_jump_velocity = 300.0
@export var second_jump_velocity_increment = 50.0
@export var max_jump_velocity = 1000.0
@export var explosion_primary_color: Color
@export var explosion_secondary_color: Color

@export var max_scale: float = 2
@export var scale_velocity: float = 0.01

var current_jump_velocity = 600.0
var status :PlayerState
var direction = 0
var jump_count = 0

func _ready() -> void:
	GameManager.update_respawn_point(position)
	current_jump_velocity = start_jump_velocity
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	
	print(global_position)
	
	if scale.x < max_scale:
		scale += scale * delta * scale_velocity
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	direction = Input.get_axis("move_left", "move_right")
	
	match status:
		PlayerState.IDLE:
			idle_state(delta)
		PlayerState.WALKING:
			walking_state(delta)
		PlayerState.JUMPING:
			jumping_state(delta)
		PlayerState.DUCKING:
			ducking_state(delta)
		PlayerState.HURTED:
			hurted_state(delta)

	move_and_slide()

# Go to state funcions

func go_to_idle_state():
	status = PlayerState.IDLE
	anim.play("idle")
	jump_count = 0
	
func go_to_walking_state():
	status = PlayerState.WALKING
	anim.play("walking")
	jump_count = 0
	
func go_to_jumping_state():
	status = PlayerState.JUMPING
	current_jump_velocity = min(current_jump_velocity + jump_velocity_increment, max_jump_velocity)
	jump()
	play_jump_effect()
	anim.play("jumping")
	
func go_to_ducking_state():
	status = PlayerState.DUCKING
	set_small_collider()
	anim.play("duck")
	
func exit_from_ducking_state():
	set_large_collider()
	
func go_to_hurted_state():
	status = PlayerState.HURTED
	collisionShape.shape.height = 42
	anim.play("hurted")
	emit_signal("player_death")
	
func exit_from_hurted_state():
	collisionShape.shape.height = 82
	
# Update state funcions
	
func idle_state(delta):
	
	decelerate(delta)
	
	set_h_flip()
	
	if Input.is_action_just_pressed("jump"):
		go_to_jumping_state()
		return
		
	if Input.is_action_just_pressed("duck"):
		go_to_ducking_state()
		return
	
	if direction != 0:
		go_to_walking_state()
		return

func walking_state(delta):
	
	move(delta)
	set_h_flip()
	
	if Input.is_action_just_pressed("jump"):
		go_to_jumping_state()
		return
		
	if Input.is_action_just_pressed("duck"):
		go_to_ducking_state()
		return
		
	if velocity.x == 0:
		go_to_idle_state()
		return

func jumping_state(delta):
	
	move(delta)
	set_h_flip()
	
	if Input.is_action_just_pressed("jump") && jump_count == 0:
		second_jump()
		return
	
	if is_on_floor():
		if direction == 0:
			go_to_idle_state()
		else:
			go_to_walking_state()
		return

func ducking_state(delta):
	
	decelerate(delta)
	set_h_flip()
	
	if not Input.is_action_pressed("duck"):
		exit_from_ducking_state()
		go_to_idle_state()
		
func hurted_state(delta):
	decelerate(delta)
		
# Private funcs

func jump():
	velocity.y = -current_jump_velocity
	
func second_jump():
	if velocity.y < 0: # Se está caindo
		if -second_jump_velocity < velocity.y:
			velocity.y = -second_jump_velocity
	else: # Se está subindo
		# Evitar que a soma dos pulos passe da velocidade máxima de pulo 
		if velocity.y - second_jump_velocity < 0:
			velocity.y = -second_jump_velocity
		else:
			velocity.y -= second_jump_velocity
			
	second_jump_velocity = min(current_jump_velocity, second_jump_velocity + second_jump_velocity_increment)
	play_second_jump_effect()
	jump_count += 1

func play_jump_effect():
	var range_velocity = max_jump_velocity - start_jump_velocity
	var current = current_jump_velocity - start_jump_velocity
	var percent = current / range_velocity
	var pitch_range = 0.7
	var start_pitch = 1.2
	var current_pitch = start_pitch - pitch_range * percent
	jump_effect.pitch_scale = current_pitch
	jump_effect.play()

func play_second_jump_effect():
	var range_velocity = max_jump_velocity
	var current = second_jump_velocity
	var percent = current / range_velocity
	var pitch_range = 0.7
	var start_pitch = 1.2
	var current_pitch = start_pitch - pitch_range * percent
	second_jump_effect.pitch_scale = current_pitch
	second_jump_effect.volume_linear = percent
	second_jump_effect.play()

func set_h_flip():
	if velocity.x > 0:
		anim.flip_h = false
	elif velocity.x < 0:
		anim.flip_h = true
	elif direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false
		
func move(delta):
	if direction != 0:
		accelerate(delta)
	else:
		decelerate(delta)

func accelerate(delta):
	velocity.x = move_toward(velocity.x, max_speed * direction, acceleration * delta)
	
func decelerate(delta):
	velocity.x = move_toward(velocity.x, 0, deceleration * delta)

func water():
	water_effect.play()
	go_to_hurted_state()
	
func respawn():
	exit_from_hurted_state()
	position = GameManager.get_respawn_point()
	set_large_collider()
	visible = true
	go_to_idle_state()

func set_small_collider():
	collisionShape.shape.height = 60
	collisionShape.position.y = -30
	hitBox.shape.size.y = 60
	hitBox.position.y = 10
	
func set_large_collider():
	collisionShape.shape.height = 80
	collisionShape.position.y = -40
	hitBox.shape.size.y = 80
	hitBox.position.y = 0

func _on_hitbox_area_entered(area: Area2D) -> void:
	
	if status == PlayerState.HURTED:
		return
	
	match area.collision_layer:
		8: # enemy_hitbox
			hit_enemy(area)
		32: # water
			water()
		128: # death zone
			go_to_hurted_state()

func hit_enemy(area: Area2D):
	if velocity.y <= 0:
		jump()
		go_to_hurted_state()
		explosion_timer.start()
		return
	
	var enemy_node = area.get_parent()
	
	if enemy_node == null:
		push_warning("Enemy node not found")
		return
	
	if !enemy_node.has_method("take_damage"):
		push_warning("Func not found (take_damage)")
		return
		
	if !enemy_node.has_method("get_is_imortal"):
		push_warning("Func not found (get_is_imortal)")
		return
		
	jump()
	
	if enemy_node.get_is_imortal():
		go_to_hurted_state()
		explosion_timer.start()
		return
		
	enemy_node.take_damage()

func _on_explosion_timer_timeout() -> void:
	ExplosionManager.create_emplosion(
		position,
		explosion_primary_color,
		explosion_secondary_color,
		1.0)
	
	visible = false
