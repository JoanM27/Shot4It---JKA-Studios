extends Node2D

# --- Nodos de UI ---
@onready var txt_tiempo = $UI/TextoTiempo
@onready var txt_muertes_j1 = $UI/MuertesJ1
@onready var txt_muertes_j2 = $UI/MuertesJ2
@onready var txt_conex_j1 = $UI/ConexionesJ1
@onready var txt_conex_j2 = $UI/ConexionesJ2
@onready var timer_juego = $TimerJuego

# --- Contadores ---
var muertes_j1: int = 0
var muertes_j2: int = 0
var conexiones_j1: int = 0
var conexiones_j2: int = 0

func _ready() -> void:
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
	var tiempo_sobrante = int(timer_juego.time_left)
	
	# REGLA: Si nadie conectó, nadie gana
	if conexiones_j1 == 0 and conexiones_j2 == 0:
		print("¡TIEMPO AGOTADO! Ningún jugador hizo conexiones. EMPATE POR INACTIVIDAD.")
		return
		
	# --- LA FÓRMULA DE PUNTUACIÓN ---
	# (Conexiones * 5000) - (Muertes * 500) + (Segundos sobrantes * 10)
	var pts_j1 = (conexiones_j1 * 5000) - (muertes_j1 * 500) + (tiempo_sobrante * 10)
	var pts_j2 = (conexiones_j2 * 5000) - (muertes_j2 * 500) + (tiempo_sobrante * 10)
	
	# Evitamos puntuaciones negativas si murieron demasiado
	pts_j1 = max(0, pts_j1)
	pts_j2 = max(0, pts_j2)
	
	print("--- RESULTADOS FINALES ---")
	print("Puntaje J1: ", pts_j1)
	print("Puntaje J2: ", pts_j2)
	
	if pts_j1 > pts_j2: print("¡GANA EL JUGADOR 1!")
	elif pts_j2 > pts_j1: print("¡GANA EL JUGADOR 2!")
	else: print("¡EMPATE POR PUNTOS!")
