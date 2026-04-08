extends Node

# --- INTERRUPTOR DE MODO ---
# Si está en true: Jugador 1 = Mando/Flechas, Jugador 2 = WASD
# Si está en false: Jugador 1 = Sufijo 1, Jugador 2 = Sufijo 2 normales
var modo_hibrido: bool = true 

# --- FUNCIÓN TRADUCTORA (La magia ocurre aquí) ---
# --- FUNCIÓN TRADUCTORA ACTUALIZADA ---
func obtener_sufijo(id_jugador: int) -> String:
	# Si el modo híbrido está activo, el Jugador 1 usa el sufijo "3" (Teclado WASD)
	if id_jugador == 1 and modo_hibrido:
		return "3"
	
	# El Jugador 2 devolverá "2", y usará el mando que le asignes en el Mapa de Entrada
	return str(id_jugador)

# --- SISTEMA DE MOVIMIENTO ---
func obtener_direccion(id_jugador: int) -> Vector2:
	var sufijo = obtener_sufijo(id_jugador)
	return Input.get_vector("izquierda_" + sufijo, "derecha_" + sufijo, "arriba_" + sufijo, "abajo_" + sufijo)

# --- SISTEMA DE DISPARO ---
func presiono_disparo(id_jugador: int) -> bool:
	var sufijo = obtener_sufijo(id_jugador)
	return Input.is_action_just_pressed("disparar_" + sufijo)

func mantiene_disparo(id_jugador: int) -> bool:
	var sufijo = obtener_sufijo(id_jugador)
	return Input.is_action_pressed("disparar_" + sufijo)

func solto_disparo(id_jugador: int) -> bool:
	var sufijo = obtener_sufijo(id_jugador)
	return Input.is_action_just_released("disparar_" + sufijo)
