# DÜŞMAN 4: Mitoz Hücresi (Bölünen Düşman)
# Görevi: Öldüğünde yok olmak yerine iki adet daha küçük/hızlı düşmana bölünmek.
# İstatistikleri: Orta can, orta hız. Ölünce 2 tane küçük hücre doğurur.

extends CharacterBody2D

@export var speed: float = 70.0
@export var max_health: float = 15.0
@export var min_xp_drop: int = 8
@export var max_xp_drop: int = 15
@export var attack_damage: float = 10.0

@export var offspring_scene: PackedScene

var current_health : float
var player: Node2D
var attack_cooldown: float = 0.0

func _ready():
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float):
	if player != null:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
		
		# Hasar Kontrolü
		if attack_cooldown > 0:
			attack_cooldown -= delta
			
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider != null and collider.is_in_group("player") and attack_cooldown <= 0:
				if collider.has_method("take_damage"):
					collider.take_damage(attack_damage)
					attack_cooldown = 1.0

func take_damage(amount: float):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	var xp_drop = randi_range(min_xp_drop, max_xp_drop)
	if player != null and player.has_method("add_xp"):
		player.add_xp(xp_drop)
		
	if offspring_scene != null:
		for i in range(2):
			var new_cell = offspring_scene.instantiate()
			var random_offset = Vector2(randf_range(-15, 15), randf_range(-15, 15))
			new_cell.global_position = global_position + random_offset
			get_parent().call_deferred("add_child", new_cell)

	queue_free()
