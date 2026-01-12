class_name OscillationEnemy extends Enemy

@export var h_oscillation: bool
@export var h_range: float
@export var h_speed: float

@export var v_oscillation: bool
@export var v_range: float
@export var v_speed: float

signal change_direction

var h_timer := 0.0
var v_timer := 0.0

var direction = 1

func _physics_process(delta: float) -> void:
	move(delta)
	
func move(delta):
	h_move(delta)
	v_move(delta)
	
func h_move(delta):
	if h_oscillation:
		h_timer += delta * h_speed
		if h_timer > 2 * PI:
			h_timer -= 2 * PI
		if h_timer > PI:
			if direction == 1:
				turn(true)
		else:
			if direction == -1:
				turn(false)
			
		global_position.x = start_position.x + cos(h_timer) * h_range
		
func v_move(delta):
	if v_oscillation:
		v_timer += delta * v_speed
		global_position.y = start_position.y + sin(v_timer) * v_range

func turn(left):
	direction = -1 if left else 1
	print(direction)
	anim.flip_h = true if left else false
	emit_signal("change_direction")
