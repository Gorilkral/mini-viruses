extends TileMapLayer

@onready var player = get_tree().get_first_node_in_group("player")

# Render mesafesi (Kaç tile ötesini çizsin?)
var render_distance = 20 

func _process(_delta: float) -> void:
	if player:
		# Oyuncunun olduğu tile koordinatını bul
		var player_tile_pos = local_to_map(player.global_position)
		
		# Oyuncunun etrafındaki alanı tara ve gerekirse doldur
		# Not: Bu çok büyük haritalarda performansı etkileyebilir, 
		# o yüzden sadece oyuncu yeni bir tile'a geçtiğinde çalıştırmak daha iyidir.
		_draw_tiles_around_player(player_tile_pos)

func _draw_tiles_around_player(center_pos: Vector2i):
	for x in range(center_pos.x - render_distance, center_pos.x + render_distance):
		for y in range(center_pos.y - render_distance, center_pos.y + render_distance):
			# Eğer o koordinatta tile yoksa (get_cell_source_id == -1)
			if get_cell_source_id(Vector2i(x, y)) == -1:
				# Buraya kendi TileSet ID'ni ve koordinatlarını yaz
				set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
