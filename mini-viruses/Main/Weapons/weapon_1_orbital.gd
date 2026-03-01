# SILAH 1: YÖRÜNGE PERVANESI (ORBITAL)
# Oyuncunun etrafında dönerek temas ettiği virüsleri anında yok eder.

extends Area2D

@onready var player = get_parent()

# Taban dönme hızı
var base_rotation_speed := 4.0

func _ready():
	# SİNYAL: Muz fiziksel olarak bir bedene (düşmana) çarptığı AN "on_hit" fonksiyonunu tetikle
	body_entered.connect(on_hit)

func _process(delta: float) -> void:
	if player:
		# Oyuncuyu takip et
		global_position = player.global_position
		
		# Dönme hızını attack_speed ile çarpıyoruz (Hız aldıkça muzlar daha hızlı dönecek!)
		rotation += (base_rotation_speed * player.attack_speed) * delta
		
		# Büyüklüğü ayarla
		var aoe = player.area_of_effect
		scale = Vector2(aoe, aoe)

# MUZ BİR ŞEYE ÇARPTIĞINDA ANINDA ÇALIŞAN FONKSİYON
func on_hit(body):
	# Çarptığı şey enemy grubundaysa ve hasar alma fonksiyonu varsa
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			# 999 çarpanıyla tokadı bas!
			body.take_damage(player.attack_damage * 999)
