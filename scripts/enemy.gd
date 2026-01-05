class_name Enemy extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@export var is_imortal: bool

@export var explosion_primary_color: Color
@export var explosion_secondary_color: Color
@export var pop_pitch: float = 1.0

var start_position: Vector2

func _ready() -> void:
	start_position = global_position

func take_damage():
	disabelNode()
	ExplosionManager.create_emplosion(
		position,
		explosion_primary_color,
		explosion_secondary_color,
		pop_pitch)

func get_is_imortal() -> bool:
	return is_imortal

func respawn():
	enableNode()
		
func disabelNode():
	self.process_mode = Node.PROCESS_MODE_DISABLED
	self.visible = false
	
func enableNode():
	self.process_mode = Node.PROCESS_MODE_INHERIT
	self.visible = true
