# DÜŞMAN 5: Asit Kusan (Menzilli Düşman)
# Görevi: Oyuncuya belli bir mesafede durup uzaktan mermi fırlatmak.

extends CharacterBody2D

@export var speed: float = 50.0
@export var max_health: float = 15.0
@export var attack_range: float = 100.0
@export var fire_rate: float = 2.0
@export var min_xp_drop: int = 5
@export var max_xp_drop: int = 12

# enemy_5_ tarafından atılacak merminin dosyası burada
# bu aşağıdaki "Packedscene" ksımı değişmeli heralde
@export var projectile_scene: PackedScene

var current_health: float
var player: Node2D
var fire_cooldown= 0.5

func _ready():
	current_health=max_health
	player = get_parent().get_node("player")

func _physics_process(delta: float):
	if player != null:
		var distance = global_position.distance_to(player.global_position)
		
		if distance > attack_range:
			var direction = global_position.direction_to(player.global_position)
			velocity = direction * speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			
		fire_cooldown -= delta
			
		if fire_cooldown <= 0.0 and distance <= attack_range:
			shoot()
			fire_cooldown = fire_rate

func shoot():
	if projectile_scene != null:
		var bullet = projectile_scene.instantiate()
		bullet.global_position = global_position
		var direction = global_position.direction_to(player.global_position)
		bullet.rotation = direction.angle()
		get_parent().call_deferred("add_child", bullet)

func take_damage(amount: float):
		current_health -= amount
		if current_health <= 0:
			die()

func die():
	var xp_drop = randi_range(min_xp_drop, max_xp_drop)
	if player != null and player.has_method("gain_xp"):
		player.gain_xp(xp_drop)
	queue_free()
