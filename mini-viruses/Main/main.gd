extends Node2D

# 📦 Sahne Yolları - Klasör yapını kontrol et (res://Main/ veya res://)
var weapon_selection_scene = preload("res://Main/WeaponSelection.tscn")

func _ready() -> void:
	print("Sistem başlatıldı: Main Sahne Hazır.")
	
	# 1. ÖNCE OYUNU DURDUR (Her şeyden önce kilidi vuruyoruz)
	get_tree().paused = true
	
	# 2. Menüyü güvenli bir şekilde çağır
	call_deferred("_show_weapon_selection")

func _show_weapon_selection():
	if weapon_selection_scene:
		var menu = weapon_selection_scene.instantiate()
		# 3. Menünün her zaman en üstte görünmesi için add_child yerine 
		# direkt sahne ağacına veya mevcut düğüme ekliyoruz.
		add_child(menu)
		print("Silah seçim menüsü enjekte edildi.")
	else:
		print("HATA: WeaponSelection sahnesi yüklenemedi! Dosya yolunu kontrol et kanka.")
