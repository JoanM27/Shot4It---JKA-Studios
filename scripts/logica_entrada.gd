extends Area2D
# --- SEÑALES ---
# Esta es la línea de comunicación directa con el nodo Padre (el Tablero principal)
signal ficha_completada(id_columna, color_sufijo)

# --- VARIABLES EXPORTADAS ---
@export var id_columna: int = 1 # Configura esto del 1 al 7 en el Inspector para cada entrada
@export var celda_posicion: Vector2i # Ej: Vector2i(0, 6) para la primera columna
@export var tilemap: TileMapLayer  # Arrastra el TileMapLayer del padre aquí desde el inspector

# --- ESTADO INTERNO ---
var nivel_llenado: int = 0
var color_actual: String = ""
var procesando: bool = false # Bloquea la entrada si se está animando el disparo

# Mapeo de la fila (Y) en tu atlas del TileSet para cada color
var atlas_filas = {
	"_amarillo": 0, # Fila 0 para las entradas amarillas
	"_azul": 2      # Fila 2 para las entradas azules
}

# La celda base vacía según tu TileSet (0:2 es ficha_vacia)
const CELDA_VACIA = Vector2i(0, 2)

func _ready() -> void:
	actualizar_grafico()

# Esta es la función que llama el proyectil al chocar
func recibir_proyectil(id_jugador: int, color_sufijo: String) -> void:
	if procesando:
		print("Entrada ocupada procesando disparo. Ignorando...")
		return
	
	# 1. Lógica de llenado y saboteo
	if nivel_llenado == 0:
		# Si está vacía, toma el color del proyectil
		color_actual = color_sufijo
		nivel_llenado = 1
	else:
		if color_actual == color_sufijo:
			# Si es del mismo color, aumenta el progreso
			nivel_llenado += 1
		else:
			# SABOTEO: Si es de diferente color, resta progreso
			nivel_llenado -= 1
			print("¡Saboteo! Nivel baja a ", nivel_llenado)
			if nivel_llenado == 0:
				color_actual = "" # Vuelve a estado neutro
	
	# 2. Actualizamos el aspecto visual en el TileMap
	actualizar_grafico()
	
	# 3. Comprobamos si llegó al tope (8 impactos)
	if nivel_llenado >= 8:
		iniciar_secuencia_disparo()

# --- ACTUALIZACIÓN VISUAL ---
func actualizar_grafico() -> void:
	if not tilemap:
		push_warning("Falta asignar el TileMapLayer a la entrada ", id_columna)
		return
		
	if nivel_llenado == 0:
		tilemap.set_cell(celda_posicion, 0, CELDA_VACIA)
	else:
		# Gracias a cómo ordenaste tu atlas, el nivel_llenado coincide con la coordenada X
		# Ej: entrada_1_amarillo es 1:0, entrada_2_amarillo es 2:0, etc.
		var coord_x = nivel_llenado
		var coord_y = atlas_filas.get(color_actual, 0)
		
		# Si el nivel es 8, coord_x es 8. (8:0 es lleno_1_amarillo, 8:2 lleno_1_azul).
		tilemap.set_cell(celda_posicion, 0, Vector2i(coord_x, coord_y))

# --- ANIMACIÓN Y ENVÍO ---
func iniciar_secuencia_disparo() -> void:
	procesando = true # Bloquea que entren más balas mientras se anima
	print("¡Ficha completada! Iniciando animación de transporte...")
	
	var coord_y = atlas_filas[color_actual]
	var coord_y_anim = coord_y + 1 # Fila 1 para amarillo (animaciones), Fila 3 para azul
	
	# Pasamos a lleno_2 (0:1 o 0:3)
	tilemap.set_cell(celda_posicion, 0, Vector2i(0, coord_y_anim))
	await get_tree().create_timer(0.15).timeout
	
	# Secuencia de vaciado (del frame 1 al 5 en X)
	for i in range(1, 6):
		tilemap.set_cell(celda_posicion, 0, Vector2i(i, coord_y_anim))
		await get_tree().create_timer(0.1).timeout
	
	# Animación de transportar (6:1 o 6:3)
	tilemap.set_cell(celda_posicion, 0, Vector2i(6, coord_y_anim))
	
	# ¡AVISAMOS AL PADRE QUE LA FICHA SUBIÓ!
	# Enviamos la columna exacta y el color para que el padre procese la lógica del array
	emit_signal("ficha_completada", id_columna, color_actual)
	
	# Pequeña pausa antes de resetear la entrada
	await get_tree().create_timer(0.2).timeout
	
	# Reiniciamos la entrada a 0 para el próximo ciclo
	nivel_llenado = 0
	color_actual = ""
	actualizar_grafico()
	procesando = false
