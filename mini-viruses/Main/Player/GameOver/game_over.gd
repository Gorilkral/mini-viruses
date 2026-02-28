extends CanvasLayer

func _ready() -> void:
	# Yollar tam olarak sahne ağacındaki gibi olmalı
	# Eğer PanelContainer içindeyse doğrudan böyle çağır:
	$PanelContainer/VBoxContainer/RetryButton.pressed.connect(_on_retry_button_pressed)
	$PanelContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)

func _on_retry_button_pressed():
	# 1. Menüyü sahneden tamamen sil (Artık ekranda kalmaz)
	queue_free()
	
	# 2. Oyunu dondurmaktan çıkar (Kritik!)
	get_tree().paused = false
	
	# 3. Sahneyi baştan yükle
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().quit() # Oyundan çık
