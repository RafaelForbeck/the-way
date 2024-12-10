extends Node2D

@onready var respawn_delay: Timer = $RespawnDelay
@onready var player: Player = $Player

func _on_player_player_death() -> void:
	respawn_delay.start()

func _on_respawn_delay_timeout() -> void:
	player.respawn()
