extends AnimatableBody2D

signal Win(player)
signal Stalemate

@export var tilemap: TileMapLayer # Arrastra tu nodo TileMapLayer aquí en el inspector
@onready var animar_propulsor_derecho = $NavaNodriza/PropulsorDerecho
@onready var animar_propulsor_izquierdo = $NavaNodriza/PropulsorIzquierdo
# La celda base vacía según tu TileSet (0:2 es ficha_vacia)
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
	
	# Revisar todas las combinaciones posibles de victoria
	for c in range(cols):
		for r in range(rows):
			var p = columns[c][r]
			if p == 0:
				continue # Si está vacío, ignorar
				
			# Vertical
			if r <= rows - 4 and p == columns[c][r+1] and p == columns[c][r+2] and p == columns[c][r+3]:
				win(p)
				return
				
			# Horizontal
			if c <= cols - 4 and p == columns[c+1][r] and p == columns[c+2][r] and p == columns[c+3][r]:
				win(p)
				return
				
			# Diagonal (Arriba-Derecha o Abajo-Derecha según la perspectiva visual, matemáticamente funciona igual)
			if c <= cols - 4 and r <= rows - 4 and p == columns[c+1][r+1] and p == columns[c+2][r+2] and p == columns[c+3][r+3]:
				win(p)
				return
				
			# Diagonal inversa
			if c <= cols - 4 and r >= 3 and p == columns[c+1][r-1] and p == columns[c+2][r-2] and p == columns[c+3][r-3]:
				win(p)
				return

	# Comprobar empate: si la última fila posible de llenar (la que está más "abajo" en el array, que en tu caso es Y=5) no tiene ceros
	var is_stalemate = true
	for col in columns:
		# Como llenas hacia el techo (0), la última ficha entraría en el fondo (5).
		if col[5] == 0: 
			is_stalemate = false
			break
			
	if is_stalemate:
		stalemate()

func win(ganador: int) -> void:
	emit_signal("Win", ganador)
	print("¡EL JUGADOR ", ganador, " ES EL GANADOR CON UN CONNECT 4!")

func stalemate() -> void:
	emit_signal("Stalemate")
	print("¡EMPATE! El tablero está lleno.")
