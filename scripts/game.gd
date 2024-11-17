extends Node2D

@onready var player := $Player

func _on_death_zone_player_entered(body: Node2D) -> void:
	player.player_dead()
	player.respawn()
