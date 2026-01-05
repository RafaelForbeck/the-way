class_name FrogEnemy extends Enemy

enum FrogStates {
	waiting,
	jumping
}

@onready var left_limit: Sprite2D = $LeftLimit
@onready var right_limit: Sprite2D = $RightLimit
@onready var waiting_timer: Timer = $WaitingTimer

var status: FrogStates

const SPEED = 300.0
const JUMP_VELOCITY = -800.0

var left_x_limit: float
var right_x_limit: float

var direction: int = 1

func _ready() -> void:
	left_limit.visible = false
	right_limit.visible = false
	
	left_x_limit = left_limit.global_position.x
	right_x_limit = right_limit.global_position.x
	
	go_to_waiting()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match status:
		FrogStates.waiting:
			waiting_state()
		FrogStates.jumping:
			jumping_state()
	
	move_and_slide()

func go_to_waiting():
	status = FrogStates.waiting
	anim.play("default")
	velocity.x = 0
	check_direction()
	waiting_timer.start()
	
func go_to_jump():
	status = FrogStates.jumping
	anim.play("jumping")
	velocity.x = SPEED * direction
	velocity.y = JUMP_VELOCITY
	
func waiting_state():
	pass
	
func jumping_state():
	if velocity.y == 0:
		go_to_waiting()

func check_direction():
	if direction > 0:
		if right_x_limit < global_position.x:
			turn_left()
		else:
			turn_right()
	else:
		if left_x_limit > global_position.x:
			turn_right()
		else:
			turn_left()
	
func turn_right():
	direction = 1
	anim.flip_h = true
	
func turn_left():
	direction = -1
	anim.flip_h = false

func _on_waiting_timer_timeout() -> void:
	go_to_jump()
