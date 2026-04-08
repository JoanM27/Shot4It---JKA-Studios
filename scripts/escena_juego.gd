extends Node2D

# --- Nodos de UI ---
@onready var txt_tiempo = $UI/TextoTiempo
@onready var txt_muertes_j1 = $UI/MuertesJ1
@onready var txt_muertes_j2 = $UI/MuertesJ2
@onready var txt_conex_j1 = $UI/ConexionesJ1
@onready var txt_conex_j2 = $UI/ConexionesJ2
@onready var timer_juego = $TimerJuego

@onready var pantalla_victoria = $UI/PantallaVictoria
@onready var texto_ganador = $UI/PantallaVictoria/TextoGanador
@onready var texto_puntos = $UI/PantallaVictoria/TextoPuntos

# --- Contadores ---
var muertes_j1: int = 0
var muertes_j2: int = 0
var conexiones_j1: int = 0
var conexiones_j2: int = 0

func _ready() -> void:
	pantalla_victoria.visible = false # Aseguramos que empiece oculto
	timer_juego.timeout.connect(_on_tiempo_agotado)
	actualizar_ui()
	# Conectamos el final del tiempo
	timer_juego.timeout.connect(_on_tiempo_agotado)
	actualizar_ui()

func _process(_delta: float) -> void:
	# --- RELOJ EN PANTALLA (MM:SS) ---
	var tiempo = int(timer_juego.time_left)
	var minutos = tiempo / 60
	var segundos = tiempo % 60
	txt_tiempo.text = "%02d:%02d" % [minutos, segundos]

# --- RECEPCIÓN DE DATOS DESDE OTROS NODOS ---
func registrar_muerte(id_jugador: int) -> void:
	if id_jugador == 1: muertes_j1 += 1
	else: muertes_j2 += 1
	actualizar_ui()

func registrar_conexion(id_jugador: int) -> void:
	if id_jugador == 1: conexiones_j1 += 1
	else: conexiones_j2 += 1
	actualizar_ui()

func actualizar_ui() -> void:
	txt_muertes_j1.text = "Muertes J1: " + str(muertes_j1)
	txt_muertes_j2.text = "Muertes J2: " + str(muertes_j2)
	txt_conex_j1.text = "Puntos J1: " + str(conexiones_j1) + "/2"
	txt_conex_j2.text = "Puntos J2: " + str(conexiones_j2) + "/2"

# --- LÓGICA DE FINAL DE PARTIDA ---
func _on_tiempo_agotado() -> void:
	calcular_ganador()

func finalizar_partida_por_conexiones() -> void:
	timer_juego.stop() # Detenemos el reloj para que dé puntos extra
	calcular_ganador()

func calcular_ganador() -> void:
	# 1. PAUSAMOS EL JUEGO AL INSTANTE
	get_tree().paused = true 
	
	var tiempo_sobrante = int(timer_juego.time_left)
	var mensaje_ganador = ""
	
	# REGLA: Si nadie conectó, nadie gana
	if conexiones_j1 == 0 and conexiones_j2 == 0:
		mensaje_ganador = "¡EMPATE POR INACTIVIDAD!"
		texto_puntos.text = "Nadie logró conectar fichas."
	else:
		# La fórmula
		var pts_j1 = (conexiones_j1 * 5000) - (muertes_j1 * 500) + (tiempo_sobrante * 10)
		var pts_j2 = (conexiones_j2 * 5000) - (muertes_j2 * 500) + (tiempo_sobrante * 10)
		pts_j1 = max(0, pts_j1)
		pts_j2 = max(0, pts_j2)
		
		# Quién ganó
		if pts_j1 > pts_j2: 
			mensaje_ganador = "¡VICTORIA DEL JUGADOR 1!"
		elif pts_j2 > pts_j1: 
			mensaje_ganador = "¡VICTORIA DEL JUGADOR 2!"
		else: 
			mensaje_ganador = "¡EMPATE ÉPICO!"
			
		# Desglose de puntos para la pantalla
		texto_puntos.text = "Puntaje J1: " + str(pts_j1) + "\n" + "Puntaje J2: " + str(pts_j2)

	# 2. MOSTRAMOS LA PANTALLA
	texto_ganador.text = mensaje_ganador
	pantalla_victoria.visible = true
	

# --- FUNCIONES DE LOS BOTONES ---
func _on_btn_reiniciar_pressed() -> void:
	# Quitamos la pausa antes de reiniciar
	get_tree().paused = false 
	# Recargamos la escena actual para jugar otra vez
	get_tree().reload_current_scene()

func _on_btn_menu_pressed() -> void:
	get_tree().paused = false
	# Aquí pondrás la ruta de la escena de tu menú principal cuando la crees
	print("Yendo al menú principal...") 
	# get_tree().change_scene_to_file("res://escenas/MenuPrincipal.tscn")
