class_name Player
extends CharacterBody3D

#The "player" that is actually your enemy
#Kinda confusing

var bullet_trail = preload("res://Scenes/BulletTrail.tscn")

@onready var weapon_root:Marker3D = $WeaponRoot
@onready var bullet_spawn = $WeaponRoot/BulletSpawn

@onready var movement_timer:Timer = $MovementTimer
@onready var attack_timeout:Timer = $AttackTimeout

@onready var detection_area:Area3D = $DetectionArea
@onready var run_away_area:Area3D = $RunAwayArea

@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var attack_animation_player:AnimationPlayer = $AttackAnimationPlayer

@onready var health_progress:TextureProgressBar = $HealthBarSprite/HealthBar/HealthProgress

@export var health:int = 100
@export var damage:int = 1
@export var attack_cooldown:float = 1.0
@export var kill_the_fucker:bool = false:
	set(value):
		die()

var attack_anim = 1

var movement_speed:float = 5.0
var movement_point:Vector3 = Vector3.ZERO
var focused_enemy:Enemy = null
var hit_tween:Tween = null
var is_dead:bool = false

func _ready():
	Global.player = self
	
	attack_timeout.start(attack_cooldown)

func _physics_process(delta):
	if is_dead:
		return
	
	weapon_root.rotation.y = $Model/PlayerMesh.rotation.y
	$WhereGoing.global_position = movement_point
	
	if !movement_point or self.global_position.distance_to(movement_point) < 1.0:
		animation_player.play("RESET")
		velocity = lerp(velocity,Vector3.ZERO,0.2)
		generate_movement_point()
		move_and_slide()
		return
	
	var direction_to_point = self.global_position.direction_to(movement_point)
	velocity = lerp(velocity,direction_to_point.normalized() * movement_speed,0.2)
	move_and_slide()
	
	if !detection_area.has_overlapping_bodies():
		focused_enemy = null
		$Model/PlayerMesh.rotation.y = lerp_angle($Model/PlayerMesh.rotation.y,atan2(velocity.x,velocity.z),0.2)
	else:
		#if focused_enemy == null:
			#for body in detection_area.get_overlapping_bodies():
				#if body is Enemy and focused_enemy == null:
					#focused_enemy = body
		#else:
			#var enemy_vector = self.global_position.direction_to(focused_enemy.global_position)
			#$Model/PlayerMesh.rotation.y = lerp_angle($Model/PlayerMesh.rotation.y,atan2(enemy_vector.x,enemy_vector.z),0.2)
		if is_instance_valid(Global.enemy_director.closest_enemy_to_player):
			var enemy_vector = self.global_position.direction_to(Global.enemy_director.closest_enemy_to_player.global_position)
			$Model/PlayerMesh.rotation.y = lerp_angle($Model/PlayerMesh.rotation.y,atan2(enemy_vector.x,enemy_vector.z),0.1)
		
func attack():
	#sword_hitbox.monitoring = true
	#attack_animation_player.play("Swing"+str(attack_anim))
	#var overlapping_bodies = sword_hitbox.get_overlapping_bodies()
	#attack_anim += 1
	#if attack_anim > 2:
		#attack_anim = 1
	#await get_tree().create_timer(0.4,false).timeout
	#attack_timeout.start(attack_cooldown)
	#for body in overlapping_bodies:
		#if body is Enemy:
			#body.take_damage(damage)
	$Shoot.play()
	attack_animation_player.play("Shoot")
	if $WeaponRoot/ShootCast.is_colliding():
		$WeaponRoot/ShootCast.get_collider().take_damage(damage)
	attack_timeout.start(attack_cooldown)
	instance_bullet()

func instance_bullet():
	var bullet_inst = bullet_trail.instantiate()
	get_tree().current_scene.add_child(bullet_inst)
	bullet_inst.global_position = bullet_spawn.global_position
	bullet_inst.global_rotation = bullet_spawn.global_rotation

func take_damage(damage_amount:int):
	if is_dead:
		return
	
	print("OW")
	$Hurt.play()
	health -= damage_amount
	health_progress.value = health
	if hit_tween:
		hit_tween.stop()
	hit_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	hit_tween.tween_property($Model/PlayerMesh.get_surface_override_material(0),"emission_energy_multiplier",1.0,0.1)
	hit_tween.tween_property($Model/PlayerMesh.get_surface_override_material(0),"emission_energy_multiplier",0.0,0.1)
	
	if health <= 0:
		die()

func _on_movement_timer_timeout():
	generate_movement_point()
	attack_timeout.start(attack_cooldown)

func generate_movement_point():
	movement_point = Vector3(randf_range(-40.0,40.0),0.0,randf_range(-40.0,40.0))
	animation_player.play("Walk")
	movement_timer.start(randf_range(20.0,70.0))

func _on_run_away_area_body_entered(body):
	generate_movement_point()

func _on_detection_area_body_entered(body):
	body.in_detection_area = true

func _on_detection_area_body_exited(body):
	body.in_detection_area = false

func _on_footstep_sound_timeout():
	$FootStep.play()

func die():
	is_dead = true
	$Dead.play()
	$Dead.pitch_scale = 0.1
	Global.ui.freeze()
	
	await(get_tree().create_timer(0.9,true,false,true).timeout)
	$Dead.pitch_scale = 1.0
	
	$HealthBarSprite.hide()
	$WhereGoing.hide()
	$Shadow.hide()
	$Model.hide()
	$WeaponRoot.hide()
	
	$Splatter.show()
	$Splatter2.show()
	$BloodExplosion.emitting = true
	
	$FootstepSound.stop()
	$MovementTimer.stop()
	$AttackTimeout.stop()
