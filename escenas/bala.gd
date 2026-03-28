extends CharacterBody2D
var velocidad = 600.0
var sufijo_color: String
var id_dueno: int

@export var tablero: TileMapLayer
@onready var tilemap: TileMapLayer = get_tree().get_first_node_in_group("mapa")
@onready var animar: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	print("Bala lista y buscando cuerpos...")
	if not sufijo_color:
		sufijo_color = ""  # por si acaso está vacío
	animar.play("lanzar_proyectil" + sufijo_color)

func _physics_process(delta: float) -> void:
	# Movimiento correcto con move_and_collide (recomendado)
	var movement = Vector2(0, -velocidad * delta)   # hacia arriba (negativo en y)
	var collision = move_and_collide(movement)
	
	if collision:
		var collider = collision.get_collider()
		print("¡Colisión detectada con: ", collider.name if collider else "nada")
		
		# Daño / lógica
		if collider and collider.has_method("recibir_proyectil"):
			print("La cubeta tiene el método, procediendo a llenar...")
			collider.recibir_proyectil(id_dueno, sufijo_color)
		
		# === ANIMACIÓN DE IMPACTO ===
		animar.play("chocar_proyectil" + sufijo_color)
		
		# Desactivar colisiones inmediatamente para que no vuelva a chocar
		set_deferred("monitoring", false)
		if has_node("CollisionShape2D"):          # si usas CollisionShape
			$CollisionShape2D.set_deferred("disabled", true)
		
		# Hacerlo invisible SOLO después de que termine la animación
		await animar.animation_finished
		
		queue_free()
