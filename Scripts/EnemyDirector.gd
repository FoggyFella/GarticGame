class_name EnemyDirector
extends Node3D

#This is the enemy director AKA the thing you play as
#You should be able to spawn in enemies using moners and earn moners by damaging the player or by waiting
#Starting cash is 100

@onready var camera:Camera3D = get_tree().root.get_camera_3d()
@onready var pointer = $PointerArea

var enemies_list = {
	"Free":preload("res://Scenes/Enemies/SlimeEnemy.tscn"),
	"Guy":preload("res://Scenes/Enemies/GuyEnemy.tscn"),
	"SpiderEnemy":preload("res://Scenes/Enemies/SpiderEnemyNEW.tscn"),
	"Archer":preload("res://Scenes/Enemies/ArcherEnemy.tscn"),
	"Leader":preload("res://Scenes/Enemies/LeaderEnemy.tscn")
}
var current_enemy:PackedScene = enemies_list["Free"]
@onready var enemy_button:Button = Global.ui.free_button

var pointer_in_player_area:bool = false
var closest_enemy_to_player:Enemy = null

func _ready():
	Global.enemy_director = self

func _input(event):
	if Global.player.is_dead or Global.ui.inside_tutorial:
		return
	
	if event.is_action_pressed("place",false) and !Global.ui.mouse_over_spawn_menu:
		if !enemy_button.disabled:
			spawn_enemy()
		else:
			Global.ui.show_message("Enemy on cooldown")

func _process(delta):
	var pointer_pos = project_mouse_position(get_viewport().get_mouse_position())
	if pointer_pos != Vector3.ZERO:
		pointer.global_position = pointer_pos

func _physics_process(delta):
	var distance_to_player = 10000000000
	for enemy_node in get_tree().get_nodes_in_group("enemy_group"):
		var testing_distance = enemy_node.global_position.distance_to(Global.player.global_position)
		if testing_distance < distance_to_player:
			distance_to_player = testing_distance
			closest_enemy_to_player = enemy_node
		
func project_mouse_position(mouse_pos:Vector2) ->Vector3:
	var spaceState = get_world_3d().direct_space_state
	
	var rayStart:Vector3 = camera.project_ray_origin(mouse_pos)
	var rayEnd:Vector3 = rayStart + camera.project_ray_normal(mouse_pos) * 2000
	var params:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(rayStart,rayEnd,1)
	
	var rayInfo:Dictionary = spaceState.intersect_ray(params)
	
	if rayInfo.has("position"):
		var ray_colission_point:Vector3 = rayInfo["position"]
		return ray_colission_point
	return Vector3.ZERO

func spawn_enemy():
	var spawn_position = project_mouse_position(get_viewport().get_mouse_position())
	if is_pointer_in_player_area():
		Global.ui.show_message("Cant spawn enemy so near to player")
		return
	
	var enemy_inst = current_enemy.instantiate()
	get_tree().current_scene.add_child(enemy_inst)
	enemy_inst.global_position = spawn_position
	enemy_button.enable_cooldown()

func change_enemy(the_new_enemy:String,the_button:Button):
	current_enemy = enemies_list[the_new_enemy]
	enemy_button = the_button

func is_pointer_in_player_area():
	return Global.player.detection_area.overlaps_area(pointer)
