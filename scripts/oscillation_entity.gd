class_name OscillationEntity extends Node2D

@export var h_oscillation: bool
@export var h_range: float
@export var h_speed: float

@export var v_oscillation: bool
@export var v_range: float
@export var v_speed: float

signal change_direction(new_direction: int)

var parent: Node2D

var h_timer := 0.0
var v_timer := 0.0

var start_position: Vector2
var direction = 1

func _ready() -> void:
	parent = get_parent() as Node2D
	start_position = parent.global_position

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
			
		parent.global_position.x = start_position.x + cos(h_timer) * h_range
		
func v_move(delta):
	if v_oscillation:
		v_timer += delta * v_speed
		parent.global_position.y = start_position.y + sin(v_timer) * v_range

func turn(left):
	direction = -1 if left else 1
	emit_signal("change_direction", direction)
