extends CharacterBody2D

# --- Bala --- #
@export var bala: PackedScene


# --- Jugador --- #
@export var id_jugador: int = 1
@export var nombre_jugador: String = "Piloto" 
var sufijo_color: String = ""
var posicion_inicial: Vector2

# --- Animaciones ---<3
@onready var animar_nave = $AspectoNave
@onready var animar_disparo = $AspectoDisparo
@onready var animar_propulsor = $LlamaPropulsor
@onready var barra_recarga =  $Recarga
@onready var animar_explosion = $Explosion

# --- Nodos de Interfaz (Corazones) ---
@onready var corazon1 = $Corazones/Corazon1
@onready var corazon2 = $Corazones/Corazon2
@onready var corazon3 = $Corazones/Corazon3
@onready var lista_corazones = [corazon1, corazon2, corazon3]
@onready var etiqueta_nombre = $nombre_jugador

# --- Variables de Movimiento --- #
@export var VELOCIDAD_MAXIMA = 350.0
@export var ACELERACION = 400.0
@export var FRICCION = 400.0

# --- Variables de Rebote --- #
@export var REBOTE_BASE: float = 80.0 # Un empujoncito mínimo garantizado
@export var MULTIPLICADOR_CHOQUE: float = 0.1 # Qué tanto afecta la velocidad al choque

# --- Variables de Disparo --- #
@export var cadencia_disparo: float = 0.22  

var tiempo_ultimo_disparo: float = 0.0
var esta_disparando: bool = false          

# --- Variables de Salud y Daño ---
@export var salud_maxima: int = 9 # 3 corazones * 3 puntos
var salud_actual: int
var es_invulnerable: bool = false
@export var tiempo_invulnerabilidad: float = 0.5
@export var tiempo_reaparecer: float = 3.0

# --- Variables de Munición ---
@export var municion_maxima: int = 20
@export var tiempo_recarga: float = 1.5
var municion_actual: int
var esta_recargando: bool = false


# --- Nodos de apoyo (Asegúrate de tener estos nombres en tu escena) ---
@onready var timer_recarga = $timer_recarga
@onready var timer_invulnerable = $timer_invulnerable




func _ready():
	# Guardamos la posición exacta del inicio
	posicion_inicial = global_position
	#ASIGNAR NOMBRE 
	etiqueta_nombre.text = nombre_jugador
	# Inicializar stats
	salud_actual = salud_maxima
	municion_actual = municion_maxima
	
	# Asegurar que la explosión esté oculta y detenida al inicio
	animar_explosion.visible = false
	animar_explosion.stop()
	
	# Configurar Timers 
	timer_recarga.one_shot = true
	timer_recarga.timeout.connect(_finalizar_recarga)
	
	timer_invulnerable.one_shot = true
	timer_invulnerable.timeout.connect(func(): es_invulnerable = false)

	# (Tu código anterior de sufijos y botones...)
	sufijo_color = "_amarillo" if id_jugador == 1 else "_azul"
	animar_nave.play("estandar" + sufijo_color)
	animar_propulsor.play("estandar")
	
	
	# === CONFIGURAR COLOR DE CORAZONES ===
	var anim_corazon = "corazon_estandar" + sufijo_color
	for corazon in lista_corazones:
		corazon.play(anim_corazon)
		corazon.pause() # Pausamos para controlar el frame manualmente
		
	actualizar_corazones()


func _physics_process(delta: float) -> void:
	
	# --- SI ESTÁ MUERTO, CORTAMOS LA FÍSICA AQUÍ MISMO ---
	if salud_actual <= 0: return 
	
	var direccion = Controles.obtener_direccion(id_jugador)
	
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
	
	if salud_actual <= 0: return # No hacer nada si está muerto
	
	# --- LÓGICA DE LA BARRA VISUAL ---
	if esta_recargando:
		barra_recarga.visible = true
		# Calculamos cuánto tiempo ha pasado restando el tiempo restante al total
		barra_recarga.value = tiempo_recarga - timer_recarga.time_left
	else:
		barra_recarga.visible = false
		
	# --- LÓGICA DE DISPARO CORREGIDA ---
	if Controles.presiono_disparo(id_jugador) and not esta_recargando:
		intentar_disparar()
		tiempo_ultimo_disparo = 0.0
		esta_disparando = true
	
	elif Controles.mantiene_disparo(id_jugador) and esta_disparando and not esta_recargando:
		tiempo_ultimo_disparo += delta
		
		if tiempo_ultimo_disparo >= cadencia_disparo:
			intentar_disparar() 
			tiempo_ultimo_disparo = 0.0
	
	if Controles.solto_disparo(id_jugador):
		esta_disparando = false
		tiempo_ultimo_disparo = 0.0

# --- SISTEMA DE DISPARO Y RECARGA ---
func intentar_disparar():
	if municion_actual > 0:
		disparar()
		municion_actual -= 1
	else:
		iniciar_recarga()

func iniciar_recarga():
	if esta_recargando: return
	esta_recargando = true
	print("Recargando...")
	timer_recarga.start(tiempo_recarga)

func _finalizar_recarga():
	municion_actual = municion_maxima
	esta_recargando = false
	print("¡Munición lista!")

# --- SISTEMA DE DAÑO Y MUERTE ---
func recibir_dano(cantidad: int):
	if es_invulnerable or salud_actual <= 0: return
	
	salud_actual -= cantidad
	actualizar_corazones()
	es_invulnerable = true
	timer_invulnerable.start(tiempo_invulnerabilidad)
	
	if salud_actual <= 0:
		morir()
	else:
		efecto_parpadeo_dano()

# Efecto HSV: Saturación (S) de 0 a 100 (Rojizo)
func efecto_parpadeo_dano():
	var tween = create_tween()
	# Parpadea 3 veces: Modula la saturación hacia el rojo
	for i in range(3):
		tween.tween_property(animar_nave, "modulate", Color(2, 0.5, 0.5), 0.1) # Rojo brillante
		tween.tween_property(animar_nave, "modulate", Color(1, 1, 1), 0.1)     # Normal

func morir():
	print("Jugador ", id_jugador, " ha muerto.")
	get_tree().call_group("cerebro", "registrar_muerte", id_jugador)
	animar_propulsor.visible = false
	velocity = Vector2.ZERO
	
	# Apagamos la hitbox para que sea un fantasma (Cambia el nombre si tu nodo se llama distinto)
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Reproducir animación de explosión en la posición de la nave
	animar_explosion.visible = true
	# Asegurar que la animación empiece desde el primer frame
	animar_explosion.frame = 0 
	animar_explosion.play("explosion")
	
	# Efecto HSV: Valor (V) de 100 a 0 (Oscurecer)
	var tween = create_tween()
	tween.tween_property(animar_nave, "modulate", Color(0, 0, 0), 1.0)
	
	await get_tree().create_timer(tiempo_reaparecer).timeout
	reaparecer()

func reaparecer():
	salud_actual = salud_maxima
	actualizar_corazones()
	municion_actual = municion_maxima
	animar_nave.modulate = Color(1, 1, 1)
	animar_propulsor.visible = true
	global_position = posicion_inicial
	
	# Prendemos la hitbox de nuevo
	$CollisionShape2D.set_deferred("disabled", false)
	
	# Asegurar que la explosión esté detenida y oculta al reaparecer
	animar_explosion.visible = false
	animar_explosion.stop()
	
	# Invulnerabilidad temporal al nacer
	es_invulnerable = true
	timer_invulnerable.start(2.0) 
	
	# Efecto visual de invulnerabilidad (fantasma)
	var tween = create_tween().set_loops(5)
	tween.tween_property(animar_nave, "modulate:a", 0.3, 0.2)
	tween.tween_property(animar_nave, "modulate:a", 1.0, 0.2)
	
func disparar() -> void:
	if not bala:
		push_error("La escena de la bala no está asignada!")
		return
		
	animar_disparo.play("disparo" + sufijo_color)
	var nueva_bala = bala.instantiate()
	
	nueva_bala.global_position = global_position + Vector2(0, -10)
	nueva_bala.sufijo_color = sufijo_color
	nueva_bala.id_dueno = id_jugador
	
	get_tree().root.add_child(nueva_bala)

func actualizar_corazones():
	# Recorremos los 3 corazones (índices 0, 1 y 2)
	for i in range(3):
		# Calculamos la vida matemática de ESTE corazón en específico (de 0 a 3)
		var vida_este_corazon = clamp(salud_actual - (i * 3), 0, 3)
		
		# Asignamos el frame basándonos en tu imagen
		match vida_este_corazon:
			3:
				lista_corazones[i].frame = 0 # Lleno
			2:
				lista_corazones[i].frame = 2 # Falta un tercio
			1:
				lista_corazones[i].frame = 1 # Queda un tercio
			0:
				lista_corazones[i].frame = 3 # Roto / Vacío
