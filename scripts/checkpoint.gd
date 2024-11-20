extends Area2D

@onready var anim := $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	get_tree().call_group("checkpoints", "off")
	anim.play("on")
	GameManager.update_respawn_point(position)

func off():
	anim.play("off")
