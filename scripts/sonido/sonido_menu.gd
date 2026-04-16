extends AudioStreamPlayer2D

# 1. Lista de tracks específicos para el menú
# Si vas a usar los mismos de la partida, copia las rutas anteriores aquí
var tracks_menu = [
	preload("res://assets/musica/menu/Choir Engine.mp3"),
	preload("res://assets/musica/menu/Menu Cósmico.mp3"),
	preload("res://assets/musica/menu/Órbita de Selección.mp3")
	
]

var cancion_actual: AudioStreamMP3

func _ready() -> void:
	# Importante: El menú también debe usar su bus correspondiente
	bus = "Musica"
	
	# Conectamos la señal para que sea infinito
	finished.connect(reproducir_aleatoria_menu)
	
	# Primera canción al abrir el juego
	reproducir_aleatoria_menu()

func reproducir_aleatoria_menu() -> void:
	if tracks_menu.size() == 0: return
	
	var opciones = tracks_menu.duplicate()
	
	if opciones.size() > 1 and cancion_actual != null:
		opciones.erase(cancion_actual)
		
	cancion_actual = opciones.pick_random()
	stream = cancion_actual
	play()
