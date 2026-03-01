extends Node2D

@export var enemy_scenes: Array[PackedScene]
@export var spawn_radius:float = 400.0
@export var spawn_rate: float = 1.5

var spawn_timer:float = 0.0
var player:Node2D

func _ready() :
	player = get_parent().get_node("Player")

func _process(delta: float):
	if player == null:
		return

	spawn_timer -= delta

	if spawn_timer <= 0.0:
		spawn_enemy()
		spawn_timer = spawn_rate

func spawn_enemy():
	if enemy_scenes.is_empty():
		return

	var random_scene = enemy_scenes.pick_random()

	if random_scene != null:
		var enemy = random_scene.instantiate()
		var random_angle = randf_range(0, TAU)
		var direction_vector = Vector2.RIGHT.rotated(random_angle)
		var spawn_pos = player.global_position + (direction_vector * spawn_radius)

		enemy.global_position = spawn_pos
		get_parent().call_deferred("add_child", enemy)
