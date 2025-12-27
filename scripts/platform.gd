extends AnimatableBody2D

@export var h_oscillation: bool
@export var h_range: float
@export var h_speed: float

@export var v_oscillation: bool
@export var v_range: float
@export var v_speed: float

var h_timer := 0.0
var v_timer := 0.0
var start_position: Vector2

func _ready() -> void:
	start_position = global_position

func _process(delta: float) -> void:
	move(delta)

func move(delta):
	if h_oscillation:
		h_timer += delta * h_speed
		if h_timer > 2 * PI:
			h_timer -= 2 * PI
			
		global_position.x = start_position.x + cos(h_timer) * h_range
		
	if v_oscillation:
		v_timer += delta * v_speed
		global_position.y = start_position.y + sin(v_timer) * v_range
