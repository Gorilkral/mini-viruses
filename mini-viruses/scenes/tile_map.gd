extends TileMapLayer

# Oyuncuyu başta arıyoruz
@onready var player = get_tree().get_first_node_in_group("player")

# Render mesafesi (Kaç tile ötesini çizsin?)
var render_distance = 20 

func _process(_delta: float) -> void:
	# 🔍 EĞER PLAYER BULUNAMAZSA TEKRAR ARA
	# Özellikle sahne yeni yüklendiğinde player henüz hazır olmayabilir.
	if not player:
		player = get_tree().get_first_node_in_group("player")
		return # Bu kareyi atla, bir sonraki karede player ile devam et
	
	# Oyuncunun olduğu tile koordinatını bul
	var player_tile_pos = local_to_map(player.global_position)
	
	# Çizim fonksiyonunu çağır
	_draw_tiles_around_player(player_tile_pos)

func _draw_tiles_around_player(center_pos: Vector2i):
	# 🎨 TileSet'teki kaynak ID'sini garantiye alalım
	# Senin TileSet'inde kaynak ID'si 1 olarak görünüyor
	var source_id = 1 
	
	for x in range(center_pos.x - render_distance, center_pos.x + render_distance):
		for y in range(center_pos.y - render_distance, center_pos.y + render_distance):
			var coords = Vector2i(x, y)
			
			# Eğer o koordinatta tile yoksa (-1 döner)
			if get_cell_source_id(coords) == -1:
				# (0,0) koordinatı atlas içindeki seçili tile'dır
				set_cell(coords, source_id, Vector2i(0, 0))
