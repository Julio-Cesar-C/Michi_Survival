extends CharacterBody2D


var mov_speed = 40.0

var hp = 30
var maxhp = 30
var last_movement = Vector2.UP

var exp = 0
var exp_lvl = 1
var collected_exp = 0
var time = 0

#Os Ataques:
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")
var javelin = preload("res://Player/Attack/javelin.tscn")


# Attacks nodes
@onready var iceSpearTimer = get_node("%IceSpearTime")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var javelinBase = get_node("%javelinBase")

#Upgrades
var collected_upgrades = []
var upgrade_options = []
var armor = 0
var speed = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks = 0



#IceSpear
var icespear_ammo =0
var icespear_baseamoo = 0
var icespear_attackspeed = 1.5
var icespear_level = 0

#tornado

var tornado_ammo =0
var tornado_baseamoo = 0
var tornado_attackspeed = 3
var tornado_level = 0

#Javelin
var javelin_ammo = 0
var javelin_level = 0




# Enemygo proximo
var enemy_close = []



@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("WalkTimer")
@onready var anim = $AnimationPlayer


#GUI
@onready var expBar = get_node("%ExpBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var itemOptions = preload("res://Utility/item_option.tscn")
@onready var sndLevelUp = get_node("%snd_levelup")
@onready var healthbar = get_node("%HealthBar")
@onready var lblTimer = get_node("%lblTimer")
@onready var collectedWeapons = get_node("%CollectedWeapons")
@onready var collectedUpgrades = get_node("%CollectedUpgrades")
@onready var itemContainer = preload("res://Player/GUI/item_container.tscn")

@onready var deathPanel = get_node("%DeathPanel")
@onready var lblResult = get_node("%lbl_Result")
@onready var sndVictory = get_node("%snd_victory")
@onready var sndLose = get_node("%snd_lose")


#signal
signal  playerdeath()




func _ready():
	upgrade_character("icespear1")
	attack()
	#anim.play("RESET")
	anim.play("Walk")
	set_expBar(exp, calculate_expcap())
	_on_hurtbox_hurt(0,0,0)
	
		
	

func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed * (1-spell_cooldown)
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed* (1-spell_cooldown)
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
	if javelin_level > 0:
		spawn_javelin()



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
	if mov != Vector2.ZERO:
		last_movement = mov
	#	if walkTimer.is_stopped():
	#		if sprite.frame >= sprite.hframes -1:
	#			sprite.frame = 0
	#		else:
	#				sprite.frame += 1
	#	walkTimer.start()
				
	
	
	
	velocity = mov.normalized() * mov_speed
	move_and_slide()


func _on_hurtbox_hurt(damage, _angle, _knockback):
	hp -= clamp(damage-armor,1.0,999.0)
	healthbar.max_value = maxhp
	healthbar.value = hp
	if hp <= 0:
		death()


func _on_ice_spear_time_timeout():
	icespear_ammo += icespear_baseamoo + additional_attacks
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


func _on_tornado_timer_timeout():
	tornado_ammo += tornado_baseamoo + additional_attacks
	tornadoAttackTimer.start()


func _on_tornado_attack_timer_timeout():
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_moviment = last_movement
	
		tornado_attack.level = tornado_level 
		add_child(tornado_attack)
		tornado_ammo -= 1
		if tornado_ammo > 0 :
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()


func spawn_javelin():
	var get_javelin_total = javelinBase.get_child_count()
	var calc_spawns = (javelin_ammo + additional_attacks) - get_javelin_total
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns -=1
	# atualiza javelin
	var get_javelins = javelinBase.get_children()
	for i in get_javelins:
		if i.has_method("update_javelin"):
			i.update_javelin()






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
	




func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_exp(gem_exp)
		

func calculate_exp(gem_exp):
	var exp_required = calculate_expcap()
	collected_exp += gem_exp
	if exp + collected_exp >= exp_required: #level up
		collected_exp -= exp_required - exp
		exp_lvl += 1
		exp = 0
		exp_required = calculate_expcap()
		levelup()
		
	else:
		exp += collected_exp
		collected_exp = 0
		
	set_expBar(exp, exp_required)
	
func calculate_expcap():
	var exp_cap = exp_lvl
	if exp_lvl < 20:
		exp_cap = exp_lvl * 5
	elif exp_lvl < 40:
		exp_cap + 95  * (exp_lvl - 19 ) * 8
	else:
		exp_cap = 255 + (exp_lvl-39) * 12
	return exp_cap



func set_expBar(set_value= 1 , set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value

func levelup():
	sndLevelUp.play()
	lblLevel.text = str("Level: ", exp_lvl)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel,"position",Vector2(220,50),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1 
		
	get_tree().paused = true
	


func upgrade_character(upgrade):
	match upgrade:
		"icespear1":
			icespear_level = 1
			icespear_baseamoo += 1
		"icespear2":
			icespear_level = 2
			icespear_baseamoo += 1
		"icespear3":
			icespear_level = 3
		"icespear4":
			icespear_level = 4
			icespear_baseamoo += 2
		"tornado1":
			tornado_level = 1
			tornado_baseamoo += 1
		"tornado2":
			tornado_level = 2
			tornado_baseamoo += 1
		"tornado3":
			tornado_level = 3
			tornado_attackspeed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_baseamoo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			mov_speed += 20.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			spell_cooldown += 0.05
		"ring1","ring2":
			additional_attacks += 1
		"food":
			hp += 20
			hp = clamp(hp,0,maxhp)
	
	adjust_gui_collection(upgrade)
	
	attack()
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(800,50)
	get_tree().paused = false
	calculate_exp(0)
	


func get_random_item():
	var dbList = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades: #encontra os upgrades ja coletados
			pass
		elif i in upgrade_options: #se **já** for uma opção
			pass
		elif UpgradeDb.UPGRADES[i]["type"]== "item": #não pega comida
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0: # ver se tem prerequisito
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades:
					to_add = false
			if to_add:
					dbList.append(i)
		else:
			dbList.append(i)
	if dbList.size()>0:
		var radomitem= dbList.pick_random()
		upgrade_options.append(radomitem)
		return radomitem
	else:
		return null


func change_time(argtime = 0):
	time = argtime
	var get_m = int(time/60.0)
	var get_s = time % 60
	if get_m < 10:
		get_m = str(0,get_m)
	if get_s < 10:
		get_s = str(0,get_s)
	lblTimer.text = str(get_m,":",get_s)
	

func adjust_gui_collection(upgrade):
	var get_upgraded_displayname = UpgradeDb.UPGRADES[upgrade]["displayname"]
	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]
	if get_type != "item":
		var get_collected_displaynames = []
		for i in collected_upgrades:
			get_collected_displaynames.append(UpgradeDb.UPGRADES[i]["displayname"])
		if not get_upgraded_displayname in get_collected_displaynames:
			var new_item = itemContainer.instantiate()
			new_item.upgrade = upgrade
			match get_type:
				"weapon":
					collectedWeapons.add_child(new_item)
				"upgrade":
					collectedUpgrades.add_child(new_item)


func death():
	deathPanel.visible = true
	emit_signal("playerdeath")
	get_tree().paused = true
	var tween = deathPanel.create_tween()
	tween.tween_property(deathPanel,"position",Vector2(220,50),3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	if time >= 300:
		lblResult.text = "Você ganhou!!!"
		sndVictory.play()
	else:
		lblResult.text = "Você perdeu =("
		sndLose.play()


func _on_btn_menu_click_end():
	get_tree().paused = false
	var _level = get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
