extends Sprite3D

var textures = [preload("res://Assets/Textures/Splatter1.png"),preload("res://Assets/Textures/Splatter2.png"),preload("res://Assets/Textures/Splatter3t.png")]

func _ready():
	rotation.y = randf_range(-360.0,360.0)
	scale *= randf_range(2.0,3.0)
	texture = textures.pick_random()
	global_position.y = 0.123
