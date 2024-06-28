extends Camera3D

var velocity:Vector3 = Vector3.ZERO

var zoom_input:float = size
var zoom_velocity:float

@export var max_zoom = 35.0
@export var min_zoom = 16.0
@export var scroll = 1.0

func _process(delta):
	var move_direction = Input.get_vector("move_left","move_right","move_up","move_down")
	var move_vector = Vector3(move_direction.x,0.0,move_direction.y)*0.5
	
	if !move_direction:
		velocity = lerp(velocity,Vector3.ZERO,0.1)
	else:	
		velocity = lerp(velocity,move_vector,0.2)
	
	self.global_position += velocity
	
	self.global_position.x = clamp(self.global_position.x,-50.0,50.0)
	self.global_position.z = clamp(self.global_position.z,-30.0,60.0)
	
	size = lerp(size,zoom_input,0.08)
	
	size = clamp(size,min_zoom,max_zoom)

func _input(event):
	if event.is_action_pressed("mouse_scroll_up"):
		zoom_input -= scroll
	if event.is_action_pressed("mouse_scroll_down"):
		zoom_input += scroll
	zoom_input = clamp(zoom_input,min_zoom,max_zoom)
