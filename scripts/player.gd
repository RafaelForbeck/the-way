extends CharacterBody2D

enum PlayerState { IDLE, WALKING, JUMPING }

@onready var anim = $AnimatedSprite2D

@export var max_speed = 300.0
@export var deceleration = 1200.0
@export var acceleration = 1600.0
@export var jump_velocity = -600.0

var status = PlayerState.JUMPING
var direction = 0

func _physics_process(delta: float) -> void:
	
	direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = move_toward(velocity.x, max_speed * direction, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
	
	match status:
		PlayerState.IDLE:
			idle_state()
		PlayerState.WALKING:
			walking_state()
		PlayerState.JUMPING:
			jumping_state(delta)
	
	if velocity.x > 0:
		anim.flip_h = false
	elif velocity.x < 0:
		anim.flip_h = true
		
	move_and_slide()

func go_to_idle_state():
	status = PlayerState.IDLE
	anim.play("idle")
	
func go_to_walking_state():
	status = PlayerState.WALKING
	anim.play("walking")
	
func go_to_jumping_state():
	status = PlayerState.JUMPING
	velocity.y = jump_velocity
	anim.play("jumping")
	
func idle_state():
	if Input.is_action_just_pressed("jump"): # and is_on_floor():
		go_to_jumping_state()
	if direction != 0:
		go_to_walking_state()

func walking_state():
	if Input.is_action_just_pressed("jump"): # and is_on_floor():
		go_to_jumping_state()
	if velocity.x == 0:
		go_to_idle_state()

func jumping_state(delta):
	if is_on_floor():
		if direction == 0:
			go_to_idle_state()
		else:
			go_to_walking_state()
	else:
		velocity += get_gravity() * delta
		
