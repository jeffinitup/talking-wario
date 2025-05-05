extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BrandonSummon_pressed():
	get_parent().get_node("VideoPlayer").play()
	get_parent().get_node("VideoPlayer").visible = true
	


func _on_VideoPlayer_finished():
	print("Done")
	get_parent().get_node("VideoPlayer").queue_free()
	queue_free()
