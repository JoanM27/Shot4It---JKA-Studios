extends Area2D 

# Exportamos las variables para que puedas ajustar la velocidad base desde el Inspector
@export var min_velocidad: float = 150.0
@export var max_velocidad: float = 350.0
@export var min_rotacion: float = -0.8  
@export var max_rotacion: float = 0.8   
@export var puntos_dano: int = 1

@export var min_velocidad_x: float = -100.0 
@export var max_velocidad_x: float = 100.0  

var velocidad_caida: float
var velocidad_rotacion: float
var velocidad_horizontal: float

# --- NUEVAS VARIABLES ---
var destruido: bool = false # Evita que el código se ejecute dos veces

@onready var sprite_principal = $Sprite2D
@onready var anim_destruccion = $Destruccion

func _ready() -> void:
	# Aleatorizamos un poco su comportamiento
	velocidad_caida = randf_range(min_velocidad, max_velocidad)
	velocidad_rotacion = randf_range(min_rotacion, max_rotacion)
	velocidad_horizontal = randf_range(min_velocidad_x, max_velocidad_x)
	
	# Aseguramos que la explosión esté oculta al aparecer
	anim_destruccion.visible = false
	anim_destruccion.stop()
	
	# Prevenir error si la señal ya se conectó desde el editor
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
func _physics_process(delta: float) -> void:
	# Si el meteoro ya chocó, detenemos la caída y rotación
	if destruido: return
	
	# Caer y girar
	global_position.x += velocidad_horizontal * delta # Mueve a los lados
	global_position.y += velocidad_caida * delta      # Mueve hacia abajota
	rotation += velocidad_rotacion * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Si sale de la pantalla sin chocar, se elimina normal
	if not destruido:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Ignorar colisiones si ya se está destruyendo
	if destruido: return
	
	if body.has_method("recibir_dano"):
		body.recibir_dano(puntos_dano)
		iniciar_destruccion()

# --- NUEVA FUNCIÓN LÓGICA ---
func iniciar_destruccion() -> void:
	destruido = true
	
	# 1. Apagar colisiones para no causar daño infinito
	set_deferred("monitoring", false)
	
	# 2. Ocultar la roca y mostrar la explosión
	sprite_principal.visible = false
	anim_destruccion.visible = true
	
	# 3. Reproducir animación 
	anim_destruccion.play("destruccion") 
	
	# 4. Pausar el código hasta que la animación termine
	await anim_destruccion.animation_finished
	
	# 5. Eliminar el nodo de la memoria
	queue_free()
	print("meteorito destruido")
