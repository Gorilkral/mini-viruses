extends Area2D

var speed = 300.0
var damage = 10.0
var direction = Vector2.RIGHT

func _ready():
	# Mermiyi fırlatıldığı yöne çevir
	rotation = direction.angle()
	
	# Çarpışma sinyalini kodla (garanti şekilde) bağla
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		
	# Yok olma süresini (Timer) bağla
	if has_node("Timer") and not $Timer.timeout.is_connected(_on_timer_timeout):
		$Timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	# EĞER ÇARPTIĞIMIZ ŞEY "player" İSE:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free() # Oyuncuya çarpınca yok ol!

func _on_timer_timeout():
	queue_free() # 5 saniye uçtuktan sonra oyunu kastırmaması için kendi kendini siler
