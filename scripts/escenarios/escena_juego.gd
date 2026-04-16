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

@onready var texto_evento_1 = $UI/Eventos/TextoEvento1
@onready var texto_evento_2 = $UI/Eventos/TextoEvento2

@onready var musica_escena = $MusicaEscena
@onready var sonido_cabina = $Cabina

var frases_epicas = [
	"¡%s CONECTA 4!",
	"¡%s ES IMPARABLE!",
	"¡GOLPE TÁCTICO DE %s!",
	"¡%s DOMINA EL TABLERO!",
	"¡QUÉ JUGADA DE %s!",
	"¡%s SUMA Y SIGUE!"
]

# --- Contadores ---
var muertes_j1: int = 0
var muertes_j2: int = 0
var conexiones_j1: int = 0
var conexiones_j2: int = 0

func _ready() -> void:
	musica_escena.play()
	sonido_cabina.play()
	pantalla_victoria.visible = false # Aseguramos que empiece oculto
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
	# 1. Sumamos el punto
	if id_jugador == 1: conexiones_j1 += 1
	else: conexiones_j2 += 1
	actualizar_ui()
	
	# 2. Obtenemos el nombre real del jugador desde el Singleton
	var nombre = Global.nombre_j1 if id_jugador == 1 else Global.nombre_j2
	
	
	# 3. Lanzamos el efecto en pantalla
	mostrar_mensaje_epico(id_jugador, nombre)

func mostrar_mensaje_epico(id_jugador: int, nombre_jugador: String) -> void:
	Audio.reproducir("connect4")
	# 1. Elegimos qué Label vamos a animar
	var label_objetivo: Label
	if id_jugador == 1:
		label_objetivo = texto_evento_1
	else:
		label_objetivo = texto_evento_2
		
	# 2. Elegimos y asignamos la frase
	var frase = frases_epicas.pick_random()
	label_objetivo.text = frase % nombre_jugador
	
	# 3. Preparamos el Label para la animación
	label_objetivo.visible = true
	label_objetivo.modulate.a = 0.0
	label_objetivo.scale = Vector2(0.5, 0.5)
	label_objetivo.pivot_offset = label_objetivo.size / 2
	
	# --- LA ANIMACIÓN INDEPENDIENTE ---
	var tween = create_tween()
	
	tween.set_parallel(true)
	tween.tween_property(label_objetivo, "modulate:a", 1.0, 0.3)
	tween.tween_property(label_objetivo, "scale", Vector2(1.2, 1.2), 0.3).set_trans(Tween.TRANS_BOUNCE)
	
	tween.set_parallel(false)
	tween.tween_property(label_objetivo, "modulate:a", 0.0, 0.5).set_delay(2.0)
func actualizar_ui() -> void:
	txt_muertes_j1.text = "Muertes "+Global.nombre_j1 +": "+ str(muertes_j1)
	txt_muertes_j2.text = "Muertes "+Global.nombre_j2 +": "+ str(muertes_j2)
	txt_conex_j1.text = "Puntos "+Global.nombre_j1 + ": " + str(conexiones_j1) + "/2"
	txt_conex_j2.text = "Puntos "+Global.nombre_j2 + ": "+ str(conexiones_j2) + "/2"

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
			mensaje_ganador = "¡VICTORIA DE "+Global.nombre_j1.capitalize()
		elif pts_j2 > pts_j1: 
			mensaje_ganador = "¡VICTORIA DE "+Global.nombre_j2.capitalize()
		else: 
			mensaje_ganador = "¡EMPATE ÉPICO!"
			
		# Desglose de puntos para la pantalla
		texto_puntos.text = "Puntaje J1: " + str(pts_j1) + "\n" + "Puntaje J2: " + str(pts_j2)

	# 2. MOSTRAMOS LA PANTALLA
	texto_ganador.text = mensaje_ganador
	pantalla_victoria.visible = true
	

# --- FUNCIONES DE LOS BOTONES ---
func _on_btn_reiniciar_pressed() -> void:
	Audio.reproducir("menu")
	# Quitamos la pausa antes de reiniciar
	get_tree().paused = false 
	# Recargamos la escena actual para jugar otra vez
	get_tree().reload_current_scene()

func _on_btn_menu_pressed() -> void:
	Audio.reproducir("menu")
	get_tree().paused = false
	# Aquí pondrás la ruta de la escena de tu menú principal cuando la crees
	print("Yendo al menú principal...") 
	get_tree().change_scene_to_file("res://escenas/escenarios/menu_principal.tscn")
