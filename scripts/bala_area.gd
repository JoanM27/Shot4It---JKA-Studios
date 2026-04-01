extends Area2D

var velocidad: float = 300.0
var sufijo_color: String = ""
var id_dueno: int = 0
@export var puntos_dano: int = 1

# Tiempo que se queda pegado después del impacto (en segundos)
var tiempo_pegado: float = 1

@onready var animar: AnimatedSprite2D = $AnimatedSprite2D



func _ready() -> void:
	print("Bala (Area2D) lista...")
	animar.play("lanzar_proyectil" + sufijo_color)
	
	# Conectar señales
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position.y -= velocidad * delta


# ====================== COLISIONES ======================

func _on_body_entered(body: Node2D) -> void:
	procesar_colision(body)
	if body.has_method("recibir_dano"):
		body.recibir_dano(puntos_dano)

func _on_area_entered(area: Area2D) -> void:
	procesar_colision(area)


func procesar_colision(collider: Node) -> void:
	if not collider or collider == self:
		return
	
	print("¡Impacto con: ", collider.name)
	
	# Aplicar el efecto (llenar cubeta, daño, etc.)
	if collider.has_method("recibir_proyectil"):
		collider.recibir_proyectil(id_dueno, sufijo_color)
	
	# === PEGARSE AL COLLIDER ===
	pegar_al_collider(collider)


func pegar_al_collider(collider: Node) -> void:
	# 1. Detener el movimiento
	set_physics_process(false)
	
	# 2. Desactivar colisiones para evitar problemas
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	
	# 3. Reproducir animación de impacto
	animar.play("chocar_proyectil" + sufijo_color)
	
	# 4. Pegarse al objeto (reparenting)
	# Usamos call_deferred para evitar errores de jerarquía
	reparent.call_deferred(collider)
	
	# 5. Esperar el tiempo que se queda pegado + animación
	await get_tree().create_timer(tiempo_pegado).timeout
	
	# 6. Eliminar el proyectil
	queue_free()
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Si sale de pantalla sin chocar con nada, se elimina
	queue_free()
