extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var enabled = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextureButton_pressed():
	if !enabled:
		enabled = true
		get_parent().get_parent().get_node("gui").visible = true
	else:
		enabled = false
		get_parent().get_parent().get_node("gui").visible = false
		
		



