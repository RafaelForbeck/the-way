extends Node2D

@onready var primary_particles: GPUParticles2D = $PrimaryParticles
@onready var secondary_particles: GPUParticles2D = $SecondaryParticles

@onready var timer: Timer = $Timer
var primary_color: Color
var secondary_color: Color

func _ready() -> void:
	timer.start(primary_particles.lifetime)
	setup_particles(primary_particles, primary_color)
	setup_particles(secondary_particles, secondary_color)
	
func _on_timer_timeout() -> void:
	queue_free()

func set_colors(primary: Color, secondary: Color):
	primary_color = primary
	secondary_color = secondary

func setup_particles(particles: GPUParticles2D, color: Color):
	particles.emitting = true
	particles.modulate = color
	
