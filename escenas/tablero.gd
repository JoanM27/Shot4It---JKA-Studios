extends AnimatableBody2D

var pintura_jugador1: float = 0.0
var pintura_jugador2: float = 0.0
@export var capacidad_maxima: float = 100.0

func recibir_proyectil(id_jugador, color):
	if id_jugador == 1:
		pintura_jugador1 += 5.0 # Cantidad de pintura por mota
		print("Cubeta J1: ", pintura_jugador1)
	else:
		pintura_jugador2 += 5.0
		print("Cubeta J2: ", pintura_jugador2)
	
	
