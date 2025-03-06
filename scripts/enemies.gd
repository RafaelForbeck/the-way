extends Node

func respawnAll():
	get_tree().call_group("enemies", "respawn")
