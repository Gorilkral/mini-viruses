extends CanvasLayer

# Silah sahnelerini buraya preload ediyoruz (Yollar senin klasör yapına göre kanka!)
var aura_scene = preload("res://Main/Weapons/Aura.tscn")
var ranged_scene = preload("res://Main/Weapons/Ranged.tscn")
# var projectile_scene = preload("res://Main/Weapons/ProjectileWeapon.tscn") # Diğerlerini sonra ekleriz

func _ready():
	# Oyunun bu menü açıkken durması lazım ama BUTONLARIN çalışması için:
	# Bu düğümün 'Process Mode' ayarını Inspector'dan 'Always' yapmayı unutma!
	get_tree().paused = true

func start_game():
	print("Sistem Kilidi Açılıyor...")
	# Önce duraklatmayı kaldır
	get_tree().paused = false
	
	# Görünürlüğü hemen kapat ki kullanıcı oyunun başladığını anlasın
	visible = false 
	
	# Bir kare (frame) bekle ve sonra sahnede temizlik yap
	await get_tree().process_frame
	print("Menü imha edildi, iyi oyunlar kanka!")
	queue_free()


func _on_weapon_1_pressed() -> void:
	print_debug("aaaa")
	# 1. Aura'yı oluştur
	var aura = aura_scene.instantiate()
	
	# 2. Player'ı bul ve silahı ona ver
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_child(aura)
		# Silahın konumu tam player'ın merkezi olsun
		aura.position = Vector2.ZERO
	
	# 3. Oyunu devam ettir ve menüyü kapat
	start_game()

func _on_weapon_2_pressed() -> void:
	var weapon = ranged_scene.instantiate()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_child(weapon)
	start_game()
