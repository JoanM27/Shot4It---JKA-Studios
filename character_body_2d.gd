extends CharacterBody2D

# --- Variables Ajustables ---
@export var VELOCIDAD_MAXIMA = 700.0
@export var ACELERACION = 1500.0  # Qué tan rápido gana velocidad
@export var FRICCION = 1200.0     # Qué tan rápido se detiene (inercia)

func _physics_process(delta: float) -> void:
	# 1. Obtener la dirección del input (W, A, S, D)
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Lógica de Movimiento Suave
	if direccion != Vector2.ZERO:
		# Si hay input, aceleramos hacia la dirección deseada
		# move_toward evita que la velocidad sobrepase el límite bruscamente
		velocity = velocity.move_toward(direccion * VELOCIDAD_MAXIMA, ACELERACION * delta)
	else:
		# Si no hay input, aplicamos fricción para ese efecto de "deslizado"
		velocity = velocity.move_toward(Vector2.ZERO, FRICCION * delta)

	# 3. Aplicar el movimiento
	move_and_slide()
	
	# 4. Bonus: Rotación visual (opcional)
	# Esto inclina la nave un poco hacia la dirección a la que se mueve
	if direccion.x != 0:
		rotation = lerp_angle(rotation, direccion.x * 0.2, 0.1)
	else:
		rotation = lerp_angle(rotation, 0, 0.1)
