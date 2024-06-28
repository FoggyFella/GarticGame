class_name Enemy
extends CharacterBody3D

var bullet_trail = preload("res://Scenes/ArrowTrail.tscn")
var splat = preload("res://Scenes/Splatter.tscn")

@export_category("Cost")
@export var cost:int = 0

@export_category("Stats")
@export var health:int = 1
@export var damage:int = 1
@export var firerate:float = 2.0
@export var speed:float = 1
@export var speed_anger:float = 1

@export_category("Money Stats")
@export var cash_min:int = 1
@export var cash_max:int = 2

@export_category("Visual")
@export var attack_animation_player:AnimationPlayer
@export var attack_animation_name:String = ""
@export var splat_color:Color
@export var attack_trail:bool = false

var player:Player = null
@onready var hitbox:Area3D = $Hitbox
@onready var attack_ray:RayCast3D = $AttackRay
@onready var attack_timer:Timer = $AttackTimer

var in_detection_area:bool = false

var hit_tween:Tween = null

func _ready():
	hide()
	player = Global.player
	
	add_to_group("enemy_group")
	pay_the_price()
	fix_collissions()
	connect_hitbox_signals()
	$FootstepSound.timeout.connect(play_footstep_sound)
	
	
	#$Label.text = self.name

func _physics_process(delta):
	if !player:
		return
	
	var direction_to_player = Vector3.ZERO
	
	if !player.is_dead:
		direction_to_player = self.global_position.direction_to(Global.player.global_position)
	else:
		if !$CollisionShape3D.disabled:
			$CollisionShape3D.disabled = true
		direction_to_player = -self.global_position.direction_to(Global.player.global_position)
	
	if !in_detection_area:
		velocity = lerp(velocity,direction_to_player*speed,0.5)
	else:
		velocity = lerp(velocity,direction_to_player*speed_anger,0.7)
	
	move_and_slide()
	$Model/Mesh.rotation.y = lerp_angle($Model/Mesh.rotation.y,atan2(direction_to_player.x,direction_to_player.z),0.2)
	attack_ray.rotation.y = $Model/Mesh.rotation.y
	
	if attack_ray.is_colliding() and attack_timer.is_stopped():
		attack()

func pay_the_price():
	var test = Global.enemy_money - cost
	if test >= 0:
		show()
		Global.enemy_money = test
		Global.enemies_spawned += 1
		Global.money_spent += cost
	else:
		Global.enemy_director.enemy_button.disable_cooldown()
		Global.ui.show_message("Not enough money for this enemy")
		queue_free()

func attack():
	if attack_trail:
		instance_bullet()
	if attack_animation_player:
		attack_animation_player.play(attack_animation_name)
	print("Attacking")
	var collider = attack_ray.get_collider()
	if collider is Player:
		collider.take_damage(damage)
		attack_timer.start(firerate)

func fix_collissions():
	set_collision_layer_value(1,false)
	set_collision_layer_value(3,true)
	set_collision_mask_value(1,true)
	set_collision_mask_value(2,true)

func connect_hitbox_signals():
	if !hitbox:
		push_error("ENEMY DOESNT HAVE A HITBOX WHAT THE FUCK")
		return
	
	hitbox.area_entered.connect(on_hitbox_area_entered)

func on_hitbox_area_entered(the_area:Area3D):
	pass

func take_damage(how_much:int):
	health -= 1
	Global.damage_taken += 1
	if hit_tween:
		$Model/Mesh.get_surface_override_material(0).set("emission_energy_multiplier",0.0)
		hit_tween.stop()
	hit_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	hit_tween.tween_property($Model/Mesh.get_surface_override_material(0),"emission_energy_multiplier",1.0,0.1)
	hit_tween.tween_property($Model/Mesh.get_surface_override_material(0),"emission_energy_multiplier",0.0,0.1)
	if health <= 0:
		queue_free()
		var cash = randi_range(cash_min,cash_max)
		Global.enemy_money += cash
		Global.player_money += int(cash/2)
		instance_splat()

func play_footstep_sound():
	$FootStep.play()
	
func instance_bullet():
	var bullet_inst = bullet_trail.instantiate()
	get_tree().current_scene.add_child(bullet_inst)
	bullet_inst.global_position = $AttackRay/BulletSpawn.global_position
	bullet_inst.global_rotation = $AttackRay/BulletSpawn.global_rotation

func instance_splat():
	var splat_inst = splat.instantiate()
	get_tree().current_scene.add_child(splat_inst)
	splat_inst.global_position = self.global_position
	splat_inst.modulate = splat_color
