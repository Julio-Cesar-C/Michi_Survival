extends StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(object):
	if "@CharacterBody2D@" in object.name:
		explosao()
	pass # Replace with function body.
	

func explosao():
	var objects_area = $AreaExplosao.get_overlapping_bodies()
	for object in objects_area:
		if object is CharacterBody2D and "@CharacterBody2D@" in object.name:
			object.queue_free()
	queue_free()
	
	var audio_player = $explosion_sound
	audio_player.play()
