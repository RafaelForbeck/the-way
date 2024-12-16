class_name Player extends CharacterBody2D

enum PlayerState { IDLE, WALKING, JUMPING, DUCKING, HURTED }

signal player_death()

@onready var explosion_timer: Timer = $ExplosionTimer
@onready var anim = $AnimatedSprite2D
@onready var collisionShape = $CollisionShape2D
@onready var hitBox = $Hitbox/CollisionShape2D

@export var max_speed = 300.0
@export var deceleration = 1200.0
@export var acceleration = 1600.0
@export var jump_velocity = -600.0
@export var explosion_primary_color: Color
@export var explosion_secondary_color: Color

var status :PlayerState
var direction = 0

func _ready() -> void:
	GameManager.update_respawn_point(position)
	go_to_jumping_state()

func _physics_process(delta: float) -> void:
	
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
	
func go_to_walking_state():
	status = PlayerState.WALKING
	anim.play("walking")
	
func go_to_jumping_state():
	status = PlayerState.JUMPING
	jump()
	anim.play("jumping")
	
func go_to_ducking_state():
	status = PlayerState.DUCKING
	collisionShape.shape.height = 50
	collisionShape.position.y = 16
	hitBox.shape.size.y = 50
	hitBox.position.y = 16
	anim.play("duck")
	
func exit_from_ducking_state():
	collisionShape.shape.height = 84
	collisionShape.position.y = 5
	hitBox.shape.size.y = 82
	hitBox.position.y = 7
	
func go_to_hurted_state():
	status = PlayerState.HURTED
	collisionShape.shape.height = 42
	anim.play("hurted")
	emit_signal("player_death")
	explosion_timer.start()
	
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
	velocity.y = jump_velocity
		
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

func player_dead():
	go_to_hurted_state()
	
func respawn():
	exit_from_hurted_state()
	position = GameManager.get_respawn_point()
	visible = true
	go_to_idle_state()

func _on_hitbox_area_entered(area: Area2D) -> void:
	
	if status == PlayerState.HURTED:
		return
	
	match area.collision_layer:
		8: # enemy_hitbox
			hit_enemy(area)
		32: # death_zone
			go_to_hurted_state()

func hit_enemy(area: Area2D):
	if velocity.y <= 0:
		jump()
		go_to_hurted_state()
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
		
	if enemy_node.get_is_imortal():
		jump()
		go_to_hurted_state()
		return
		
	enemy_node.take_damage()

func _on_explosion_timer_timeout() -> void:
	ExplosionManager.create_emplosion(position, explosion_primary_color, explosion_secondary_color)
	visible = false
