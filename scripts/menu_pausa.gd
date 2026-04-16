extends Control

func _input(event: InputEvent) -> void:
	
	# Detecta si se presiona Escape
	if event.is_action_pressed("pausa"):
		Audio.reproducir("pausa")
		alternar_pausa()

func alternar_pausa() -> void:
	
	# Invierte el estado actual (si está pausado, lo despausa y viceversa)
	var nuevo_estado = not get_tree().paused
	get_tree().paused = nuevo_estado
	visible = nuevo_estado # Muestra u oculta este menú

func _on_btn_continuar_pressed() -> void:
	Audio.reproducir("menu")
	# Quita la pausa desde el botón
	alternar_pausa()

func _on_btn_salir_menu_pressed() -> void:
	Audio.reproducir("menu")
	# Es vital quitar la pausa antes de cambiar de escena
	get_tree().paused = false
	get_tree().change_scene_to_file("res://escenas/escenarios/menu_principal.tscn")
