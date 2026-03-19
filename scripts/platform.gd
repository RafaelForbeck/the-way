extends AnimatableBody2D

@export var delay: float = 0
@export var duration: float = 1

@onready var target: Sprite2D = $Target
@onready var start_timer: Timer = $StartTimer

func _ready() -> void:
	target.visible = false
	start_timer.wait_time = delay
	start_timer.start()
	
func start_movement():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position", target.global_position, duration)
	
	tween.tween_property(self, "global_position", global_position, duration)
	tween.set_loops()

func _on_start_timer_timeout() -> void:
	start_movement()
