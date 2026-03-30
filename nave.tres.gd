extends CharacterBody2D

# --- Bala --- #
@export var bala: PackedScene

# --- Jugador --- #
@export var id_jugador: int = 1
var sufijo_color: String = ""

@onready var animar_nave = $AspectoNave
@onready var animar_disparo = $AspectoDisparo
@onready var animar_propulsor = $LlamaPropulsor

# --- Variables de Movimiento --- #
@export var VELOCIDAD_MAXIMA = 700.0
@export var ACELERACION = 1500.0
@export var FRICCION = 1200.0

# --- Variables de Rebote --- #
@export var REBOTE_BASE: float = 300.0 # Un empujoncito mínimo garantizado
@export var MULTIPLICADOR_CHOQUE: float = 0.1 # Qué tanto afecta la velocidad al choque

# --- Variables de Disparo --- #
@export var cadencia_disparo: float = 0.22  

var tiempo_ultimo_disparo: float = 0.0
var esta_disparando: bool = false          

# --- Nombres de Acciones Dinámicas --- #
var btn_izq: String
var btn_der: String
var btn_arr: String
var btn_aba: String
var btn_disparar: String

func _ready():
	sufijo_color = "_amarillo" if id_jugador == 1 else "_azul"
	animar_nave.play("estandar" + sufijo_color)
	animar_propulsor.play("estandar")
	
	btn_izq = "izquierda_" + str(id_jugador)
	btn_der = "derecha_" + str(id_jugador)
	btn_arr = "arriba_" + str(id_jugador)
	btn_aba = "abajo_" + str(id_jugador)
	btn_disparar = "disparar_" + str(id_jugador)


func _physics_process(delta: float) -> void:
	var direccion = Input.get_vector(btn_izq, btn_der, btn_arr, btn_aba)
	
	if direccion != Vector2.ZERO:
		velocity = velocity.move_toward(direccion * VELOCIDAD_MAXIMA, ACELERACION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICCION * delta)
	
	# GUARDAMOS LA VELOCIDAD ANTES DEL CHOQUE
	# Esto es vital porque move_and_slide frena la nave si toca una pared
	var velocidad_pre_choque = velocity
	
	# Ejecutamos el movimiento y detectamos colisiones
	move_and_slide()
	
	# Rotación visual
	if direccion.x != 0:
		animar_nave.skew = lerp(animar_nave.skew, direccion.x * 0.2, 0.1)
		animar_disparo.skew = lerp(animar_disparo.skew, direccion.x * 0.2, 0.1)
		animar_propulsor.skew= lerp(animar_propulsor.skew, direccion.x * 0.15, 0.1)
	else:
		animar_nave.skew = lerp(animar_nave.skew, 0.0, 0.1)
		animar_disparo.skew = lerp(animar_disparo.skew, 0.0, 0.1)
		animar_propulsor.skew= lerp(animar_propulsor.skew, 0.0, 0.1)
		
	# === LÓGICA DE REBOTE DE COLISIÓN (TIPO BILLAR) ===
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var collider = colision.get_collider()
		
		# Verificamos si chocamos contra la otra nave
		if collider and "id_jugador" in collider:
			
			# 1. DIRECCIÓN (Centro a Centro): Perfecto para hitboxes circulares
			var direccion_escape = (global_position - collider.global_position).normalized()
			
			# 2. FUERZA BASADA EN VELOCIDAD: Sumamos la velocidad de ambas naves 
			# (Para que un choque frontal sea mucho más violento que un alcance por detrás)
			var fuerza_impacto = velocidad_pre_choque.length() + collider.velocity.length()
			
			# 3. CÁLCULO FINAL: El rebote mínimo + (el impacto escalado)
			var fuerza_total = REBOTE_BASE + (fuerza_impacto * MULTIPLICADOR_CHOQUE)
			
			# 4. APLICAMOS REBOTE SÓLO A NOSOTROS MISMOS
			# (El enemigo correrá este mismo código en su turno y se rebotará a sí mismo)
			velocity = direccion_escape * fuerza_total
			
		else:
			# REBOTE CONTRA PAREDES/TABLERO
			# Las paredes son planas, así que la normal sí funciona bien aquí
			var normal_pared = colision.get_normal()
			var fuerza_impacto = velocidad_pre_choque.length()
			
			# Rebotamos contra la pared (con un poco menos de fuerza para no perder el control)
			velocity = normal_pared * (REBOTE_BASE * 0.5 + fuerza_impacto * 0.4)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed(btn_disparar):
		disparar()
		tiempo_ultimo_disparo = 0.0
		esta_disparando = true
	
	elif Input.is_action_pressed(btn_disparar) and esta_disparando:
		tiempo_ultimo_disparo += delta
		
		if tiempo_ultimo_disparo >= cadencia_disparo:
			disparar()
			tiempo_ultimo_disparo = 0.0
	
	if Input.is_action_just_released(btn_disparar):
		esta_disparando = false
		tiempo_ultimo_disparo = 0.0


func disparar() -> void:
	if not bala:
		push_error("La escena de la bala no está asignada!")
		return
		
	animar_disparo.play("disparo" + sufijo_color)
	var nueva_bala = bala.instantiate()
	
	nueva_bala.global_position = global_position + Vector2(0, -40)
	nueva_bala.sufijo_color = sufijo_color
	nueva_bala.id_dueno = id_jugador
	
	get_tree().root.add_child(nueva_bala)

# ¡ADVERTENCIA: NO VUELVAS A PONER LA FUNCIÓN "recibir_rebote" AQUÍ!
# Si lo haces, las naves se empujarán mutuamente en un bucle infinito y saldrán volando.
