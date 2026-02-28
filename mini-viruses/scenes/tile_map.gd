extends TileMapLayer

@onready var player = get_tree().get_first_node_in_group("player")

# Render mesafesi (Kaç tile ötesini çizsin?)
var render_distance = 20 

func _process(_delta: float) -> void:
	print("Sonsuz harita kodu calisiyor!")
	if player:
		var player_tile_pos = local_to_map(player.global_position)
		_draw_tiles_around_player(player_tile_pos)
	else:
		# Eğer bunu konsolda görüyorsan player'ı bulamıyor demektir!
		print("HATA: Player bulunamadı! Grubu kontrol et.")
		player = get_tree().get_first_node_in_group("player") # Tekrar bulmayı dene

func _draw_tiles_around_player(center_pos: Vector2i):
	# TileSet'teki ilk kaynağın (Atlas) ID'sini otomatik al
	var atlas_source_id = tile_set.get_source_id(0) 
	
	for x in range(center_pos.x - render_distance, center_pos.x + render_distance):
		for y in range(center_pos.y - render_distance, center_pos.y + render_distance):
			var coords = Vector2i(x, y)
			
			# Eğer o koordinat boşsa (-1)
			if get_cell_source_id(coords) == -1:
				# Buradaki (0,0) atlas içindeki ilk karedir
				set_cell(coords, atlas_source_id, Vector2i(0, 0))
