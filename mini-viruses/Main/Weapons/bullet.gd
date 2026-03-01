extends Area2D

var speed = 400.0
var damage = 10.0
var direction = Vector2.RIGHT

func _ready():
	# Mermi doğduğunda yönüne göre dönmesini sağlar
	rotation = direction.angle()

func _physics_process(delta):
	# Belirlenen yöne doğru dümdüz git
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free() # Düşmana çarpınca mermi silinsin

func _on_death_timer_timeout():
	queue_free() # Menzil dışına çıkınca silin
