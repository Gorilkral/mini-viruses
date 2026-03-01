extends Area2D

var level: int = 1
var hp: int = 1
var speed: float = 100.0
var damage: int = 5
var knock_amount: float = 100.0
var attack_size: float = 1.0

var target: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	# Eğer oyuncu varsa hedefi oyuncu yap
	if player:
		target = player.global_position

	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)

	match level:
		1:
			hp = 1
			speed = 100.0
			damage = 5
			knock_amount = 100.0
			attack_size = 1.0


func _physics_process(delta: float) -> void:
	position += angle * speed * delta


func enemy_hit(charge: int = 1) -> void:
	hp -= charge
	if hp <= 0:
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
