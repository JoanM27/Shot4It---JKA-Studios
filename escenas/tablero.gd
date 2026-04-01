extends AnimatableBody2D

signal Win(player)
signal Stalemate


@export var tilemap: TileMapLayer # Arrastra tu nodo TileMapLayer aquí en el inspector
@onready var animar_propulsor_derecho = $NavaNodriza/PropulsorDerecho
@onready var animar_propulsor_izquierdo = $NavaNodriza/PropulsorIzquierdo

# --- Variables de Puntuación ---
@export var puntos_para_ganar: int = 2
var puntos_jugador1: int = 0
var puntos_jugador2: int = 0

# La coordenada de ficha bloqueada en el TileSet
const TILE_BLOQUEADO = Vector2i(0, 4)

# La celda base vacía 
const CELDA_VACIA = Vector2i(0, 2)


# Tablero 2D: 7 columnas (X: 0-6), cada una con 6 filas (Y: 0-5).
# Y=0 es el techo de tu tablero, Y=5 es la base de tu tablero.
var columns = [
	[0,0,0,0,0,0], [0,0,0,0,0,0], [0,0,0,0,0,0], [0,0,0,0,0,0],
	[0,0,0,0,0,0], [0,0,0,0,0,0], [0,0,0,0,0,0]
]



func _ready() -> void:
	
	#iniciar propulsores #
	animar_propulsor_derecho.play("Estandar")
	animar_propulsor_izquierdo.play("Estandar")
	# Limpiamos el tablero visualmente por si acaso
	for x in range(7):
		for y in range(6):
			tilemap.set_cell(Vector2i(x, y), 0, CELDA_VACIA)
			
	# Conectamos las 7 áreas de entrada con LA RUTA EXACTA de tu árbol
	for i in range(1, 8):
		# Generamos la ruta: "casillas/Entradas/entrada1", "casillas/Entradas/entrada2", etc.
		var ruta_exacta = "casillas/Entradas/entrada" + str(i)
		var entrada_nodo = get_node(ruta_exacta)
		
		if entrada_nodo:
			entrada_nodo.ficha_completada.connect(_on_ficha_completada)
		else:
			push_error("No se encontró la ruta: " + ruta_exacta)

# Esta función la llaman las Entradas cuando llegan a 8 impactos
func _on_ficha_completada(id_columna: int, color_sufijo: String) -> void:
	# Traducimos el color a ID de jugador
	var jugador = 1 if color_sufijo == "_amarillo" else 2
	
	# Animamos y aplicamos la ficha (es una corrutina porque usa await)
	procesar_subida_ficha(id_columna, jugador, color_sufijo)

func procesar_subida_ficha(id_columna: int, jugador: int, color_sufijo: String) -> void:
	# Ajustamos a índices de array (0 a 6)
	var x = id_columna - 1 
	var target_y = -1
	
	# BUSCAMOS EL OBJETIVO (Gravedad hacia el techo)
	# Como Y=0 es el techo y Y=5 es el suelo del tablero, revisamos de 0 a 5.
	# El primer 0 que encontremos será la posición más alta disponible.
	for y in range(6):
		if columns[x][y] == 0:
			target_y = y
			break
			
	if target_y == -1:
		print("¡La columna ", id_columna, " ya está llena!")
		return # No hay espacio
		
	# Definimos los tiles correctos según el jugador
	var tile_transportar: Vector2i
	var tile_lleno: Vector2i
	
	if color_sufijo == "_amarillo":
		tile_transportar = Vector2i(6, 1)
		tile_lleno = Vector2i(0, 1)
	else:
		tile_transportar = Vector2i(6, 3)
		tile_lleno = Vector2i(0, 3)

	# --- ANIMACIÓN DE SUBIDA ---
	# Empieza en 5 (el fondo del tablero) y sube hasta target_y
	for current_y in range(5, target_y - 1, -1):
		# Borramos la estela visual de la posición por la que acaba de pasar
		if current_y < 5:
			tilemap.set_cell(Vector2i(x, current_y + 1), 0, CELDA_VACIA)
			
		# Dibujamos el tile de transporte
		tilemap.set_cell(Vector2i(x, current_y), 0, tile_transportar)
		
		# Esperamos un instante para dar el efecto de movimiento
		await get_tree().create_timer(0.05).timeout

	# --- FICHA EN POSICIÓN ---
	# Ponemos el tile definitivo ("lleno_2")
	tilemap.set_cell(Vector2i(x, target_y), 0, tile_lleno)
	
	# Actualizamos la lógica matemática
	columns[x][target_y] = jugador
	
	# Verificamos victoria
	check_board(jugador)

func check_board(jugador: int) -> void:
	var cols = 7
	var rows = 6
	
	for c in range(cols):
		for r in range(rows):
			var p = columns[c][r]
			
			# Ignoramos si está vacío (0) o si es una ficha ya bloqueada (9)
			if p == 0 or p == 9: 
				continue 
				
			# Vertical
			if r <= rows - 4 and p == columns[c][r+1] and p == columns[c][r+2] and p == columns[c][r+3]:
				bloquear_fichas(p, [Vector2i(c,r), Vector2i(c,r+1), Vector2i(c,r+2), Vector2i(c,r+3)])
				return
				
			# Horizontal
			if c <= cols - 4 and p == columns[c+1][r] and p == columns[c+2][r] and p == columns[c+3][r]:
				bloquear_fichas(p, [Vector2i(c,r), Vector2i(c+1,r), Vector2i(c+2,r), Vector2i(c+3,r)])
				return
				
			# Diagonal (Hacia abajo)
			if c <= cols - 4 and r <= rows - 4 and p == columns[c+1][r+1] and p == columns[c+2][r+2] and p == columns[c+3][r+3]:
				bloquear_fichas(p, [Vector2i(c,r), Vector2i(c+1,r+1), Vector2i(c+2,r+2), Vector2i(c+3,r+3)])
				return
				
			# Diagonal (Hacia arriba)
			if c <= cols - 4 and r >= 3 and p == columns[c+1][r-1] and p == columns[c+2][r-2] and p == columns[c+3][r-3]:
				bloquear_fichas(p, [Vector2i(c,r), Vector2i(c+1,r-1), Vector2i(c+2,r-2), Vector2i(c+3,r-3)])
				return

# --- COMPROBAR FIN DE JUEGO (Tablero Lleno o Muerto) ---
	var tablero_fisicamente_lleno = true
	for col in columns:
		if col[5] == 0: 
			tablero_fisicamente_lleno = false
			break
			
	# El juego termina si ya no caben fichas, O si matemáticamente nadie puede hacer nada útil
	if tablero_fisicamente_lleno or tablero_muerto():
		print("¡El tablero ya no da para más! Evaluando puntos...")
		
		if puntos_jugador1 > puntos_jugador2:
			print("¡Victoria por puntos para el Jugador 1!")
			win(1)
		elif puntos_jugador2 > puntos_jugador1:
			print("¡Victoria por puntos para el Jugador 2!")
			win(2)
		else:
			stalemate()
	# --- COMPROBAR FIN DE JUEGO POR TABLERO LLENO ---
	var tablero_lleno = true
	for col in columns:
		# Si hay al menos un espacio libre en la última fila, el juego sigue
		if col[5] == 0: 
			tablero_lleno = false
			break
			
	# Si el tablero se llenó de fichas basura y ya no cabe nada más:
	if tablero_lleno:
		print("¡Tablero lleno! Evaluando puntos...")
		
		# Gana el que tenga más puntos (Ej: 1 a 0)
		if puntos_jugador1 > puntos_jugador2:
			print("¡Victoria por puntos para el Jugador 1!")
			win(1)
		elif puntos_jugador2 > puntos_jugador1:
			print("¡Victoria por puntos para el Jugador 2!")
			win(2)
		# Solo hay empate real si ambos tienen los mismos puntos (0-0 o 1-1)
		else:
			stalemate()
func bloquear_fichas(jugador: int, coordenadas: Array) -> void:
	# Recorremos las 4 coordenadas ganadoras
	for pos in coordenadas:
		# 1. Las transformamos en "9" en la matriz para que el código las ignore
		columns[pos.x][pos.y] = 9 
		
		# 2. Cambiamos su dibujo en el TileMap por tu ficha en (0, 4)
		tilemap.set_cell(pos, 0, TILE_BLOQUEADO)
		
	# 3. Sumar puntos y verificar si ya ganaron la partida
	if jugador == 1:
		puntos_jugador1 += 1
		print("¡Jugador 1 anota! Puntos: ", puntos_jugador1)
		if puntos_jugador1 >= puntos_para_ganar:
			win(1)
	else:
		puntos_jugador2 += 1
		print("¡Jugador 2 anota! Puntos: ", puntos_jugador2)
		if puntos_jugador2 >= puntos_para_ganar:
			win(2)
func win(ganador: int) -> void:
	emit_signal("Win", ganador)
	print("¡EL JUGADOR ", ganador, " ES EL GANADOR CON UN CONNECT 4!")

func stalemate() -> void:
	emit_signal("Stalemate")
	print("¡EMPATE! El tablero está lleno.")

# --- RADAR PREDICTIVO ---
func tablero_muerto() -> bool:
	var cols = 7
	var rows = 6
	
	for c in range(cols):
		for r in range(rows):
			# Revisar hacia Abajo
			if r <= rows - 4:
				if linea_posible(columns[c][r], columns[c][r+1], columns[c][r+2], columns[c][r+3]): return false
			# Revisar hacia la Derecha
			if c <= cols - 4:
				if linea_posible(columns[c][r], columns[c+1][r], columns[c+2][r], columns[c+3][r]): return false
			# Revisar Diagonal Abajo-Derecha
			if c <= cols - 4 and r <= rows - 4:
				if linea_posible(columns[c][r], columns[c+1][r+1], columns[c+2][r+2], columns[c+3][r+3]): return false
			# Revisar Diagonal Arriba-Derecha
			if c <= cols - 4 and r >= 3:
				if linea_posible(columns[c][r], columns[c+1][r-1], columns[c+2][r-2], columns[c+3][r-3]): return false

	# Si revisó todo el tablero y ninguna línea es posible, el tablero está muerto
	return true

func linea_posible(c1: int, c2: int, c3: int, c4: int) -> bool:
	var linea = [c1, c2, c3, c4]
	
	# Si hay una ficha muerta (9), nadie puede usar esta línea
	if 9 in linea: return false
	
	var tiene_j1 = 1 in linea
	var tiene_j2 = 2 in linea
	
	# Si la línea tiene fichas de AMBOS jugadores, ya está bloqueada para los dos
	if tiene_j1 and tiene_j2: return false
	
	# Si llegamos aquí, la línea está vacía, o solo tiene fichas de un jugador. ¡Aún es ganable!
	return true
