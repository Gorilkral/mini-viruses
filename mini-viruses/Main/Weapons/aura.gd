extends Area2D

var timer := 0.0

# Aura, Player'ın altında olduğu için parent'a (oyuncuya) erişiyoruz
@onready var player = get_parent()

func _process(delta: float) -> void:
	if player:
		var aoe = player.area_of_effect
		scale = Vector2(aoe, aoe)
		
		var current_interval = 1.0 / player.attack_speed
		
		timer += delta
		if timer >= current_interval:
			apply_aura_damage()
			timer = 0.0

func apply_aura_damage():
	var targets = get_overlapping_bodies()
	for target in targets:
		if target.is_in_group("enemy"):
			if target.has_method("take_damage"):
				target.take_damage(player.attack_damage)
