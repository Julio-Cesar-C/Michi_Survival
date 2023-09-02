extends CharacterBody2D


var mov_speed = 40.0

var hp = 80

#Os Ataques:
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")

# Attacks nodes
@onready var iceSpearTimer = get_node("%IceSpearTime")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")

#IceSpear
var icespear_ammo =0
var icespear_baseamoo = 1
var icespear_attackspeed = 1.5
var icespear_level = 1

# Enemygo proximo
var enemy_close = []



@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("WalkTimer")
@onready var anim = $AnimationPlayer


func _ready():
	attack()
	#anim.play("RESET")
	anim.play("Walk")
	
		
	

func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()




func _physics_process(delta):
	movement()
	
func movement():
	var x_mov =  Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov,y_mov)
	
	if mov.x >0:
		sprite.flip_h = true
	elif mov.x <0:
		sprite.flip_h = false
		
	
	
	if mov.y or mov.x != 0:
		anim.play("Walk")
	else: anim.play("RESET")
	#if mov != Vector2.ZERO:
	#	if walkTimer.is_stopped():
	#		if sprite.frame >= sprite.hframes -1:
	#			sprite.frame = 0
	#		else:
	#				sprite.frame += 1
	#	walkTimer.start()
				
	
	
	
	velocity = mov.normalized() * mov_speed
	move_and_slide()


func _on_hurtbox_hurt(damage):
	hp -= damage
	print(hp)


func _on_ice_spear_time_timeout():
	icespear_ammo += icespear_baseamoo
	iceSpearAttackTimer.start()


func _on_ice_spear_attack_timer_timeout():
	if icespear_ammo > 0:
		var icespear_attack = iceSpear.instantiate()
		icespear_attack.position = position
		icespear_attack.target = get_random_target()
		icespear_attack.level = icespear_level 
		add_child(icespear_attack)
		icespear_ammo -= 1
		if icespear_ammo > 0 :
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP


func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)
	

func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)
	
