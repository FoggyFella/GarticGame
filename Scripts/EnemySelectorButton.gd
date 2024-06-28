extends Button

@export var the_enemy_name:String = "Free"
@export var cooldown:float = 3

var cooldown_timer:Timer

func _ready():
	self.pressed.connect(on_pressed)
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_left)
	focus_entered.connect(on_mouse_entered)
	focus_exited.connect(on_mouse_left)
	self.focus_mode = Control.FOCUS_NONE
	self.pivot_offset.x = self.size.x/2
	self.pivot_offset.y = self.size.y/2
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.timeout.connect(on_timer_timeout)
	$Cooldown.hide()
	$Label.show()

func on_pressed():
	button_pressed = true
	
	for button in button_group.get_buttons():
		button.scale_down()
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"scale",Vector2(1.15,1.15),0.1)
	
	Global.enemy_director.change_enemy(the_enemy_name,self)
	
func scale_down():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"scale",Vector2(1.0,1.0),0.1)

func enable_cooldown():
	disabled = true
	cooldown_timer.start(cooldown)
	$Cooldown.show()
	$Label.hide()

func disable_cooldown():
	cooldown_timer.stop()
	set_deferred("disabled",false)
	$Cooldown.set_deferred("visible",false)
	$Label.set_deferred("visible",true)

func on_timer_timeout():
	disabled = false
	$Cooldown.set_deferred("visible",false)
	$Label.set_deferred("visible",true)

func on_mouse_entered():
	if self.disabled == false and !self.button_pressed:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(self,"scale",Vector2(1.15,1.1),0.1)
		tween.tween_property(self,"scale",Vector2(1.05,1.05),0.3)

func on_mouse_left():
	if self.disabled == false and !has_focus() and !self.button_pressed:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(self,"scale",Vector2(0.9,0.7),0.1)
		tween.tween_property(self,"scale",Vector2(1.0,1.0),0.3)
