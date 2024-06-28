extends Node

#NODE REFERENCES
var player = null
var enemy_director = null
var ui = null

#IMPORTANT STATS
var enemy_money:int = 5:
	set(value):
		enemy_money = value
		emit_signal("stats_changed")
var player_money:int = 0:
	set(value):
		player_money = value
		emit_signal("stats_changed")
var saw_tutorial:bool = false

signal stats_changed

#STATS FOR END SCREEN
var enemies_spawned:int = 0
var damage_taken:int = 0
var money_spent:int = 0

var timer_on:bool = false


var time = 0
var time_text = "0"

func _process(delta):
	if(timer_on):
		time += delta
	
	var mils = fmod(time,1)*1000
	var secs = fmod(time,60)
	var mins = fmod(time,60*60) / 60
	var time_passed = "%02d : %02d : %03d" % [mins,secs,mils]
	
	time_text = time_passed

func wipe_stats():
	enemies_spawned= 0
	damage_taken = 0
	money_spent = 0
	player_money = 0
	enemy_money = 0

func start_timer():
	timer_on = true

func stop_timer():
	timer_on = false

func reset_timer():
	time = 0
	time_text = "0"
