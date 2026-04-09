extends Line2D

# Cuántos puntos (largo) tendrá la estela
@export var largo_maximo: int = 15

func _ready() -> void:
	# Nos aseguramos de empezar sin puntos basura
	clear_points()

func _physics_process(_delta: float) -> void:
	# 1. Obtenemos la posición actual del padre (el meteorito)
	var posicion_padre = get_parent().global_position
	
	# 2. Añadimos un nuevo punto en la cabeza de la línea
	add_point(posicion_padre)
	
	# 3. Si la estela es muy larga, borramos el punto más viejo (la cola)
	if get_point_count() > largo_maximo:
		remove_point(0)
