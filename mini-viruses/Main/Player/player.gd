extends CharacterBody2D

@onready var attack_timer = $AttackTimer
@onready var attack_range = $AttackRange
var upgrade_menu_scene = preload("res://Main/Player/Upgrade/UpgradeMenu.tscn")

@export_group("Can")
@export var max_health := 100.0
var current_health: float

@export_group("Saldırı")
@export var attack_damage := 10.0
@export var attack_speed := 1.0 
@export var area_of_effect := 1.0 
@export var projectile_count := 1.0

@export_group("Hareket")
@export var speed := 300.0

var death = false

func _ready() -> void:
	current_health = max_health
	print("Karakter Hazır! Can: ", current_health)
	
	# Güvenlik önlemi: Eğer Timer sahne ağacında yoksa hata vermesin
	if attack_timer:
		attack_timer.wait_time = 1.0 / attack_speed
		# Fonksiyonu bağlarken self.shoot şeklinde yazmak bazen daha garantidir
		attack_timer.timeout.connect(self.shoot)
		attack_timer.start() # Autostart seçmediysen buradan başlatıyoruz

func shoot() -> void:
	# Menzil alanı veya düğüm silindiyse hata vermemesi için kontrol
	if not is_instance_valid(attack_range): return
	
	var targets = attack_range.get_overlapping_bodies()
	var closest_enemy = null
	var shortest_distance = INF 

	for body in targets:
		if body.is_in_group("enemy"):
			var distance = global_position.distance_to(body.global_position)
			if distance < shortest_distance:
				shortest_distance = distance
				closest_enemy = body

	if closest_enemy:
		print("Hedef kilitlendi: ", closest_enemy.name)
		# Mermi fırlatma kodu buraya gelecek
	print_debug("fonksiyon calisiyo la")
	
	
func apply_upgrade(upgrade_type: String, value: float):
	match upgrade_type:
		"speed":
			speed += value
		"attack_speed":
			attack_speed += value
			if attack_timer:
				attack_timer.wait_time = 1.0 / attack_speed
		"damage":
			attack_damage += value
		"health":
			max_health += value
			current_health += value
		"aoe":
			area_of_effect += value
			# Updates the visual/collision range
			attack_range.scale = Vector2(area_of_effect, area_of_effect)
		"projectile_count":
			# You should add this variable at the top of player.gd: var projectile_count = 1
			projectile_count += int(value)

# Tecrübe puanı sistemi
var level := 1
var xp := 0.0
var xp_required := 100.0

func add_xp(amount: float):
	xp += amount
	if xp >= xp_required:
		xp = xp - xp_required
		if has_node("LvlSound"):
			$LvlSound.play()
		level = level + 1
		xp_required = xp_required + 10
		level_up()
func add_health(amount: float):
	if current_health < max_health:
		current_health = current_health + amount
		if current_health > max_health:
			current_health = max_health

func level_up():
	print("Level Up! Menü açılıyor...") # Test için kalsın
	
	# 1. Menüyü hafızaya al (instantiate)
	var menu = upgrade_menu_scene.instantiate()
	
	# 2. Menüyü sahne ağacına ekle (Ekranda görünmesi için şart)
	get_tree().root.add_child(menu)
	
	# 3. Oyunu durdur (Menüdeki butonlara basana kadar her şey donsun)
	get_tree().paused = true
	

var game_over_scene = preload("res://Main/Player/GameOver/GameOver.tscn") # Dosya yoluna dikkat!

func take_damage(amount: float):
	current_health -= amount
	print("Can gitti! Kalan: ", current_health)
	
	if current_health <= 0:
		die()

func die():
	if has_node("DeathSound"):
		$DeathSound.play()
	
	current_health = 0
	if death == false:
		print("Öldün!")
		death = true
		await get_tree().create_timer(1.0).timeout
		get_tree().paused = true
		var screen = game_over_scene.instantiate()
		get_tree().root.add_child(screen)



func _input(event):
	# Klavyede 'L' tuşuna basınca anında level atlatır
	if event is InputEventKey and event.pressed and event.keycode == KEY_L:
		add_xp(xp_required)
	if event is InputEventKey and event.pressed and event.keycode == KEY_K:
		take_damage(20) # K'ye her bastığında 20 can gider
	
	

	
func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()
		
	print_debug(velocity)
