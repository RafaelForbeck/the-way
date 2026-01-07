class_name FrogEnemy extends Enemy

enum FrogStates {
	waiting,
	jumping
}

@onready var left_limit: Sprite2D = $LeftLimit
@onready var right_limit: Sprite2D = $RightLimit
@onready var player_detector_left: ShapeCast2D = $PlayerDetectorLeft
@onready var player_detector_right: ShapeCast2D = $PlayerDetectorRight

var status: FrogStates

const SPEED = 300.0
const JUMP_VELOCITY = -800.0

var left_x_limit: float
var right_x_limit: float

var beyond_left = false
var beyond_right = false

var direction: int = 1

var waiting_time = 0

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
			waiting_state(delta)
		FrogStates.jumping:
			jumping_state()
	
	move_and_slide()

func go_to_waiting():
	status = FrogStates.waiting
	anim.play("default")
	velocity.x = 0
	check_direction()
	
func go_to_jump():
	status = FrogStates.jumping
	anim.play("jumping")
	velocity.x = SPEED * direction
	velocity.y = JUMP_VELOCITY
	waiting_time = 0
	
func waiting_state(delta):
	waiting_time += delta
	if waiting_time >= 3:
		go_to_jump()
		return
	
	if player_detector_left.is_colliding() and beyond_left == false:
		turn_left()
		
	if player_detector_right.is_colliding() and beyond_right == false:
		turn_right()

	if (player_detector_left.is_colliding() or player_detector_right.is_colliding()) and waiting_time > 1:
		go_to_jump()
		return
	
func jumping_state():
	if velocity.y == 0:
		go_to_waiting()

func check_direction():
	
	beyond_right = false
	beyond_left = false
	
	if direction > 0:
		if right_x_limit < global_position.x:
			beyond_right = true
			turn_left()
		else:
			turn_right()
	else:
		if left_x_limit > global_position.x:
			beyond_left = true
			turn_right()
		else:
			turn_left()
	
func turn_right():
	direction = 1
	anim.flip_h = true
	
func turn_left():
	direction = -1
	anim.flip_h = false
