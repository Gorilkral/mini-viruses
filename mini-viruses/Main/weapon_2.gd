extends Button


func _on_weapon_2_pressed():
	var orb_scene = preload("res://Weapons/Orb.tscn") # Yolun doğruluğundan emin ol knk!
	var orb_instance = orb_scene.instantiate()
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_child(orb_instance)
	
	# 🚀 ÖNEMLİ: Menüyü kapat ve oyunu başlat
	get_tree().paused = false
	queue_free()
