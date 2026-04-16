extends AudioStreamPlayer2D
# 1. Cargamos todas las obras maestras de Andrés aquí
var lista_canciones = [
	preload("res://assets/musica/juego/Circuit Choir.mp3"),
	preload("res://assets/musica/juego/Circuito En Llamas (1).mp3"),
	preload("res://assets/musica/juego/Circuito En Llamas.mp3"),
	preload("res://assets/musica/juego/Neon Killstreak.mp3"),
	preload("res://assets/musica/juego/Neón de Impacto x Circuit Breaker Run (Mashup).mp3"),
	preload("res://assets/musica/juego/Núcleo Oscuro (1).mp3"),
	preload("res://assets/musica/juego/Núcleo Oscuro.mp3")
	# Añade las demás rutas de la misma manera separadas por comas...
]

var cancion_actual: AudioStream

func _ready() -> void:
	# Nos aseguramos de que suene en el canal correcto de tu consola de mezclas
	bus = "Musica" 
	
	# Esto es magia: Le decimos a Godot "cuando termines de sonar, llama a la función otra vez"
	finished.connect(reproducir_aleatoria)
	
	# ¡Que empiece la fiesta!
	reproducir_aleatoria()

func reproducir_aleatoria() -> void:
	# Copiamos la lista para poder manipularla
	var opciones = lista_canciones.duplicate()
	
	# Evitamos que suene la misma canción dos veces seguidas (si hay más de 1)
	if opciones.size() > 1 and cancion_actual != null:
		opciones.erase(cancion_actual)
		
	# Elegimos una al azar
	cancion_actual = opciones.pick_random()
	
	# La ponemos en el reproductor y le damos play
	stream = cancion_actual
	play()
