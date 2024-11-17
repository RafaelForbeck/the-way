extends CharacterBody2D

enum PlayerState { IDLE, WALKING, JUMPING, DUCKING }

@onready var anim = $AnimatedSprite2D
@onready var collisionShape = $CollisionShape2D

@export var max_speed = 300.0
@export var deceleration = 1200.0
@export var acceleration = 1600.0
@export var jump_velocity = -600.0

var status = PlayerState.JUMPING
var direction = 0

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	direction = Input.get_axis("move_left", "move_right")
	
	if velocity.x > 0:
		anim.flip_h = false
	elif velocity.x < 0:
		anim.flip_h = true
	elif direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false
	
	match status:
		PlayerState.IDLE:
			idle_state(delta)
		PlayerState.WALKING:
			walking_state(delta)
		PlayerState.JUMPING:
			jumping_state(delta)
		PlayerState.DUCKING:
			ducking_state(delta)

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
	
func go_to_ducking_state():
	status = PlayerState.DUCKING
	collisionShape.shape.height = 50
	collisionShape.position.y = 16
	anim.play("duck")
	
func exit_from_ducking_state():
	collisionShape.shape.height = 84
	collisionShape.position.y = 5
	
func idle_state(delta):
	
	decelerate(delta)
	
	if Input.is_action_just_pressed("jump"): # and is_on_floor():
		go_to_jumping_state()
		return
		
	if Input.is_action_just_pressed("duck"): # and is_on_floor():
		go_to_ducking_state()
		return
	
	if direction != 0:
		go_to_walking_state()
		return

func walking_state(delta):
	
	move(delta)
	
	if Input.is_action_just_pressed("jump"): # and is_on_floor():
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
	
	if is_on_floor():
		if direction == 0:
			go_to_idle_state()
		else:
			go_to_walking_state()
		return

func ducking_state(delta):
	decelerate(delta)
	if not Input.is_action_pressed("duck"):
		exit_from_ducking_state()
		go_to_idle_state()
		
func move(delta):
	if direction != 0:
		accelerate(delta)
	else:
		decelerate(delta)

func accelerate(delta):
	velocity.x = move_toward(velocity.x, max_speed * direction, acceleration * delta)
	
func decelerate(delta):
	velocity.x = move_toward(velocity.x, 0, deceleration * delta)
