extends Control

func _on_button_pressed():
	# Butona basıldığında gerçek oyun sahnemize geçiş yap!
	# (Ana oyun sahnenin adı Main.tscn ise kod tam olarak böyledir)
	get_tree().change_scene_to_file("res://Main/Main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
