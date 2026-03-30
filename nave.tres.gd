extends CharacterBody2D

# --- Bala --- #
@export var bala: PackedScene

# --- Jugador --- #
@export var id_jugador: int = 2
@export var sufijo_color: String = "_amarillo" if id_jugador == 1 else "_azul"

@onready var animar_nave = $AspectoNave
@onready var animar_disparo = $AspectoDisparo

# --- Variables de Movimiento --- #
@export var VELOCIDAD_MAXIMA = 700.0
@export var ACELERACION = 1500.0
@export var FRICCION = 1200.0

# --- Variables de Disparo --- #
@export var cadencia_disparo: float = 0.22  # Tiempo entre disparos automáticos

var tiempo_ultimo_disparo: float = 0.0
var esta_disparando: bool = false          # Para detectar cuando empieza a mantener

func _ready():
	animar_nave.play("estandar" + sufijo_color)


func _physics_process(delta: float) -> void:
	# Movimiento (sin cambios)
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direccion != Vector2.ZERO:
		velocity = velocity.move_toward(direccion * VELOCIDAD_MAXIMA, ACELERACION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICCION * delta)
	
	move_and_slide()
	
	# Rotación visual
	if direccion.x != 0:
		skew = lerp_angle(skew, direccion.x * 0.2, 0.1)
	else:
		skew = lerp_angle(skew, 0, 0.1)


func _process(delta: float) -> void:
	# === LÓGICA DE DISPARO HÍBRIDA ===
	
	if Input.is_action_just_pressed("disparar"):
		# Disparo inmediato al presionar (una sola vez)
		disparar()
		tiempo_ultimo_disparo = 0.0
		esta_disparando = true
	
	elif Input.is_action_pressed("disparar") and esta_disparando:
		# Disparo automático mientras se mantiene la tecla
		tiempo_ultimo_disparo += delta
		
		if tiempo_ultimo_disparo >= cadencia_disparo:
			disparar()
			tiempo_ultimo_disparo = 0.0
	
	# Detectar cuando se suelta la tecla
	if Input.is_action_just_released("disparar"):
		esta_disparando = false
		tiempo_ultimo_disparo = 0.0


func disparar() -> void:
	if not bala:
		push_error("La escena de la bala no está asignada!")
		return
	animar_disparo.play("disparo"+sufijo_color)
	var nueva_bala = bala.instantiate()
	
	nueva_bala.global_position = global_position + Vector2(0, -40)
	nueva_bala.sufijo_color = sufijo_color
	nueva_bala.id_dueno = id_jugador
	
	get_tree().root.add_child(nueva_bala)
	
	# Opcional: aquí puedes poner sonido de disparo o animación de la nave
