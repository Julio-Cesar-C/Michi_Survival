extends CharacterBody2D




@export var mov_speed = 20.0

@export var hp = 10

@onready var player = get_tree().get_first_node_in_group('player')

@onready var sprite = $Sprite2D

@onready var anim = $AnimationPlayer


func _ready():
	anim.play("Walk")

func _physics_process(_delta):
	var direcao = global_position.direction_to(player.global_position)
	
	velocity = direcao * mov_speed
	move_and_slide()
	
	
	
	if direcao.x > 0.1: 
		sprite.flip_h = true
	elif direcao.x < 0.1:
		sprite.flip_h = false 


func _on_hurtbox_hurt(damage):
	hp -= damage
	if hp <= 0:
		queue_free()
