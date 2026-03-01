extends Button


func _on_weapon_1_pressed():
	var aura_scene = preload("res://Weapons/Aura.tscn") # Yolun doğruluğundan emin ol knk!
	var aura_instance = aura_scene.instantiate()
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_child(aura_instance)
	
	# 🚀 ÖNEMLİ: Menüyü kapat ve oyunu başlat
	get_tree().paused = false
	queue_free()
