# MERMİ KODU
# Sadece düz uçar, çarparsa hasar verir ve kendini yok eder.

extends Area2D

var speed := 400.0  
var damage := 10.0

func _ready():
	body_entered.connect(on_hit)
	
	var lifespan_timer = get_tree().create_timer(4.0)
	lifespan_timer.timeout.connect(queue_free)

func _process(delta: float):
	position += transform.x * speed * delta

func on_hit(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			
			queue_free()
