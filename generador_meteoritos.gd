extends Node2D

@export var meteoritos: Array[PackedScene]

# Ajustamos el tiempo a 1.0 para que el evento ocurra cada segundo exacto
@export var tiempo_espera: float = 3.0 

@onready var timer = $Timer

var limite_izquierdo: float
var limite_derecho: float
var altura_aparicion: float

func _ready() -> void:
	var tamaño_pantalla = get_viewport_rect().size
	limite_izquierdo = -(tamaño_pantalla.x / 2.0) + 30.0
	limite_derecho = (tamaño_pantalla.x / 2.0) - 30.0
	altura_aparicion = -(tamaño_pantalla.y / 2.0) - 100.0 
	
	timer.wait_time = tiempo_espera
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	if meteoritos.is_empty(): return
	
	# --- LÓGICA DE RÁFAGA ---
	# Generamos un número aleatorio entre 2 y 3 para esta ráfaga
	var cantidad_a_generar = randi_range(2, 5)
	
	for i in range(cantidad_a_generar):
		# Instanciamos uno por cada vuelta del bucle
		var escena_elegida = meteoritos.pick_random()
		var nuevo_meteorito = escena_elegida.instantiate()
		
		# Calculamos posición X
		var pos_x = randf_range(limite_izquierdo, limite_derecho)
		
		# Le damos un pequeño desfase en Y a cada uno para que no salgan 
		# exactamente en la misma línea horizontal y se vea más natural
		var desfase_y = randf_range(0, 80) 
		
		nuevo_meteorito.global_position = Vector2(pos_x, altura_aparicion - desfase_y)
		
		# Lo añadimos al mundo
		get_tree().root.add_child(nuevo_meteorito)
