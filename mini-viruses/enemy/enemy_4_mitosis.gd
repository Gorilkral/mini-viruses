# DÜŞMAN 4: Mitoz Hücresi (Bölünen Düşman)
# Görevi: Öldüğünde yok olmak yerine iki adet daha küçük/hızlı düşmana bölünmek.
# İstatistikleri: Orta can, orta hız. Ölünce 2 tane Kamçılı Hücre doğurur.

extends CharacterBody2D

@export var speed: float = 70.0
@export var max_health: float = 15.0

#diğerlerinden farklı olan kod kısmı
@export var offspring_scene: PackedScene

var current_health : float
var player: Node2D

func _ready():
	current_health = max_health
	player = get_parent().get_node("Player")

func _physics_process(delta: float):
	if player != null:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()

func take_damage(amount: float):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	if offspring_scene != null:
		for i in range(2):
			var new_cell = offspring_scene.instantiate()
			var random_offset = Vector2(randf_range(-15, 15), randf_range(-15, 15))
			new_cell.global_position = global_position + random_offset
			get_parent().call_deferred("add_child", new_cell)

	queue_free()
