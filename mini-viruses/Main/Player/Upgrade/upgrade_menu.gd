extends CanvasLayer

# Updated upgrade options in English
var upgrade_options = ["speed", "attack_speed", "damage", "health", "weapon"]

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	# 1. EĞER OTOMATİK GELİŞTİRME AÇIKSA (GİZLİ MOD)
	if player and player.auto_upgrade:
		upgrade_options.shuffle()
		var selected_stat = upgrade_options[0] # Rastgele birini seç
		
		player.apply_upgrade(selected_stat, get_upgrade_value(selected_stat))
		print("Otomatik Upgrade Yapıldı: ", selected_stat)
		
		queue_free() # Ekrana çıkmadan ve oyunu dondurmadan anında kendini sil
		return # Alt satırlardaki buton kurma kodlarına geçmesini engelle!
	
	get_tree().paused = true
	# Randomize the list so you don't get the same 3 every time
	upgrade_options.shuffle()
	
	# Prepare the buttons (Check your Node paths: $VBoxContainer/Button1 etc.)
	setup_button($PanelContainer/VBoxContainer/Option1, upgrade_options[0])
	setup_button($PanelContainer/VBoxContainer/Option2, upgrade_options[1])

func setup_button(button: Button, stat_name: String):
	# Formatting the name: "attack_speed" -> "Attack Speed"
	var display_name = stat_name.replace("_", " ").capitalize()
	button.text = "Mutation: " + display_name
	
	# Store the stat type in button's metadata
	button.set_meta("upgrade_type", stat_name)
	
	# Connect the signal if not already connected
	if not button.pressed.is_connected(_on_option_selected):
		button.pressed.connect(_on_option_selected.bind(button))

func _on_option_selected(button: Button):
	var selected_stat = button.get_meta("upgrade_type")
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		# Calling your apply_upgrade function in player.gd
		player.apply_upgrade(selected_stat, get_upgrade_value(selected_stat))
	
	# Resume game and remove the menu
	get_tree().paused = false
	queue_free()

func get_upgrade_value(stat_name: String) -> float:
	match stat_name:
		"speed": return 30.0
		"attack_speed": return 0.05
		"damage": return 10.0
		"health": return 20.0
		"weapon": return 0.05
	return 0.0
