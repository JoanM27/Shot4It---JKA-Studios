extends Control

# Referencias a las pantallas
@onready var pantalla_inicio = $PantallaInicio
@onready var pantalla_seleccion = $"PantallaSelección"

# Referencias a los campos de texto
@onready var input_j1 = $"PantallaSelección/LadoJ1/InputNombreJ1"
@onready var input_j2 = $"PantallaSelección/LadoJ2/InputNombreJ2"
@onready var sonido_menu = $Sonido_menu

func _ready() -> void:
	# Al arrancar, mostramos el inicio y ocultamos la selección
	sonido_menu.play()
	pantalla_inicio.visible = true
	pantalla_seleccion.visible = false

# --- BOTONES DE LA PANTALLA INICIO ---
func _on_btn_jugar_pressed() -> void:
	Audio.reproducir("menu")
	pantalla_inicio.visible = false
	pantalla_seleccion.visible = true

func _on_btn_salir_pressed() -> void:
	Audio.reproducir("menu")
	get_tree().quit()

# --- BOTONES DE LA PANTALLA SELECCIÓN ---
func _on_btn_volver_pressed() -> void:
	Audio.reproducir("menu")
	pantalla_seleccion.visible = false
	pantalla_inicio.visible = true

func _on_btn_normal_pressed() -> void:
	Audio.reproducir("menu")
	iniciar_juego(false) # false = Dos Mandos

func _on_btn_hibrido_pressed() -> void:
	Audio.reproducir("menu")
	iniciar_juego(true) # true = Teclado vs Mando

# Función que guarda nombres y cambia de escena
func iniciar_juego(es_hibrido: bool) -> void:
	# Los controles siguen en su propio Singleton
	Controles.modo_hibrido = es_hibrido
	
	# Ahora usamos GLOBAL para los datos del jugador
	if input_j1.text != "":
		Global.nombre_j1 = input_j1.text
		print(Global.nombre_j1)
	if input_j2.text != "":
		Global.nombre_j2 = input_j2.text
		print(Global.nombre_j2)
	# ¡Nos vamos al nivel! (Revisa que la ruta sea correcta)
	get_tree().change_scene_to_file("res://escenas/escenarios/nivel_1.tscn")
