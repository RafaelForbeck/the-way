class_name CrawlingEnemy extends Enemy

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()
	
	super._physics_process(delta)
