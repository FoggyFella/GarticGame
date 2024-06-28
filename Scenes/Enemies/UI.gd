extends CanvasLayer

@onready var free_button = $Control/UnitScroll/Margin/Hbox/Free

var mouse_over_spawn_menu:bool = false
var inside_tutorial:bool = false
var tutorial_page:int = 1


func _ready():
	Global.ui = self
	Global.stats_changed.connect(on_stats_changed)
	$WinScreen.hide()
	
	if Global.saw_tutorial:
		Global.reset_timer()
		Global.start_timer()
		$Tutorial.hide()
	else:
		inside_tutorial = true
		$Tutorial.show()

func _on_unit_scroll_mouse_entered():
	mouse_over_spawn_menu = true

func _on_unit_scroll_mouse_exited():
	mouse_over_spawn_menu = false

func on_stats_changed():
	$Control/UpperLeft/YourMoners.text = "YOUR MONEY: " + str(Global.enemy_money)
	$Control/UpperLeft/PlayerMoners.text = "PLAYER MONEY: " + str(Global.player_money)

func show_message(new_message:String):
	$Message.text = new_message
	$MessagePlayer.play("MessageShow")

func freeze():
	$White.show()
	Engine.time_scale = 0.05
	await get_tree().create_timer(1.0,true,false,true).timeout
	Engine.time_scale = 1.0
	$Control/UnitScroll.hide()
	$White.hide()
	await get_tree().create_timer(2.0,true,false,true).timeout
	show_win_screen()

func show_win_screen():
	Global.stop_timer()
	$WinScreen/BlackBg.color = Color("16132300")
	$WinScreen/ScreenStuff.modulate = Color("ffffff00")
	$WinScreen/ScreenStuff/Buttons.hide()
	
	$WinScreen/ScreenStuff/InfoStuff/Label.text = "TIME: " + Global.time_text
	$WinScreen/ScreenStuff/InfoStuff/Label2.text = "ENEMIES SPAWNED: " + str(Global.enemies_spawned)
	$WinScreen/ScreenStuff/InfoStuff/Label3.text = "DAMAGE TAKEN: " + str(Global.damage_taken)
	$WinScreen/ScreenStuff/InfoStuff/Label4.text = "MONEY SPENT: " + str(Global.money_spent)
	
	$WinScreen.show()
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property($WinScreen/BlackBg,"color",Color("16132386"),2.0)
	tween.parallel().tween_property($WinScreen/ScreenStuff,"modulate",Color("ffffff"),2.4)
	await tween.finished
	$WinScreen/ScreenStuff/Buttons.show()

func _on_replay_pressed():
	Global.wipe_stats()
	get_tree().reload_current_scene()

func _on_exit_pressed():
	get_tree().quit()

func _on_next_button_pressed():
	for page in $Tutorial/Panel/Pages.get_children():
		page.hide()
	tutorial_page += 1
	if tutorial_page < 7:
		get_node("Tutorial/Panel/Pages/Page"+str(tutorial_page)).show()
	else:
		Global.saw_tutorial = true
		inside_tutorial = false
		$Tutorial.hide()
		Global.reset_timer()
		Global.start_timer()
