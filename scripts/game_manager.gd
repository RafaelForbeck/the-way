extends Node

var respawn_point : Vector2

func update_respawn_point(point):
	respawn_point = point
	
func get_respawn_point() -> Vector2:
	return respawn_point
