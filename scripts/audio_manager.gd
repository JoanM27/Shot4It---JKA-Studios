extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
# 1. ARCHIVOS DE AUDIO
var sonidos = {
	"marcar":preload("res://assets/sonidos/marcar.wav"),
	"reaparecer":preload("res://assets/sonidos/reaparecer.wav"),
	"formar_ficha":preload("res://assets/sonidos/formar_ficha.wav"),
	"disparo": preload("res://assets/sonidos/Disparo.wav"), 
	"choque": preload("res://assets/sonidos/chocar.wav"),
	"dano": preload("res://assets/sonidos/impacto.wav"),
	"muerte": preload("res://assets/sonidos/muerte.wav"),
	"connect4": preload("res://assets/sonidos/Connect4.wav"),
	"pausa": preload("res://assets/sonidos/Pausa.wav"),
	"menu": preload("res://assets/sonidos/menu.wav"),
	"recarga": preload("res://assets/sonidos/Recarga.wav")
}

# 2. MAPA DE BUSES (A dónde va cada sonido)
# Los nombres de la derecha deben ser idénticos a los de tu panel de Audio
var rutas_buses = {
	"marcar":"Efectos",
	"reaparecer":"Efectos",
	"formar_ficha":"Efectos",
	"disparo": "Disparo",
	"choque": "Disparo",
	"dano": "Efectos",
	"muerte": "Efectos",
	"connect4": "Ui", 
	"pausa": "Ui",
	"menu": "Ui",
	"recarga": "Efectos"
}

# 3. VOLUMEN INDIVIDUAL (En Decibelios)
# Ajusta estos números a tu gusto mientras pruebas el juego
var volumenes = {
	"marcar":0,
	"reaparecer":0,
	"formar_ficha":5.0,
	"disparo": -5.0,  # Un poco más bajo para que no aturda si disparan mucho
	"choque": -8.0,
	"dano": -10.0,      # Normal
	"muerte": 2.0,    # Un poco más fuerte para darle impacto
	"connect4": 0.0,
	"pausa": -5.0,
	"menu": -8.0,     # Bajito para que el clic sea un detalle sutil
	"recarga": -4.0
}
# 3. FUNCIÓN REPRODUCTORA
func reproducir(nombre: String, variar_tono: bool = false) -> void:
	var archivo = sonidos.get(nombre)
	if archivo == null: return
	
	var reproductor = AudioStreamPlayer.new()
	reproductor.stream = archivo
	
	# Asignar el bus
	reproductor.bus = rutas_buses.get(nombre, "Efectos")
	
	# --- APLICAR EL VOLUMEN INDIVIDUAL ---
	# Buscamos el volumen en el diccionario. Si se te olvida poner uno, usa 0.0 por defecto
	reproductor.volume_db = volumenes.get(nombre, 0.0)
	
	# Efecto de variación de tono
	if variar_tono:
		reproductor.pitch_scale = randf_range(0.85, 1.15)
		
	add_child(reproductor)
	reproductor.play()
	reproductor.finished.connect(reproductor.queue_free)
