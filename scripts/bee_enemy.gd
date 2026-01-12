class_name BeeEnemy extends OscillationEnemy

@onready var player_detector: RayCast2D = $PlayerDetector
@onready var waiting_timer: Timer = $WaitingTimer
@onready var cooldown_timer: Timer = $CooldownTimer

var player_position

enum BeeStatus {
	patrol,
	waiting,
	attacking
}

var status = BeeStatus.patrol
var cooldown = false

func _physics_process(delta: float) -> void:
	
	match status:
		BeeStatus.patrol:
			patrol(delta)
		BeeStatus.waiting:
			waiting()
		BeeStatus.attacking:
			attacking()

func go_to_patrol():
	status = BeeStatus.patrol
	
func go_to_waiting():
	status = BeeStatus.waiting
	waiting_timer.start()
	
func go_to_attacking():
	status = BeeStatus.attacking
	attack()
	
func patrol(delta):
	super._physics_process(delta)
	if player_detector.is_colliding() and cooldown == false:
		cooldown = true
		cooldown_timer.start()
		var raycast_collider = player_detector.get_collider()
		player_position = raycast_collider.global_position + Vector2.UP * 50
		go_to_waiting()
	
func waiting():
	pass
	
func attacking():
	pass

func _on_change_direction() -> void:
	player_detector.target_position.x = abs(player_detector.target_position.x) * -direction

func attack():
	var initial_position = global_position
	var target_position = player_position
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position", target_position, 0.3)
	tween.tween_property(self, "global_position", initial_position, 0.5)
	tween.connect("finished", Callable(self, "go_to_patrol"))

func _on_waiting_timer_timeout() -> void:
	go_to_attacking()

func _on_cooldown_timer_timeout() -> void:
	cooldown = false
