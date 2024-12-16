extends Node

var explosion_entity := preload("res://entities/particles_explosion.tscn")

func create_emplosion(position: Vector2, primary_color: Color, secondary_color: Color):
	var new_explosion = explosion_entity.instantiate()
	new_explosion.global_position = position
	new_explosion.set_colors(primary_color, secondary_color)
	add_child(new_explosion)
