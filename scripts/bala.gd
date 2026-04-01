extends Area2D

var velocidad = 600.0
var sufijo_color: String
var id_dueno: int

@export var tablero: TileMapLayer

@onready var tilemap: TileMapLayer = get_tree().get_first_node_in_group("mapa")
@onready var animar = $AnimatedSprite2D

func _ready():
	print("Bala lista y buscando cuerpos...")
	animar.play("lanzar_proyectil" + sufijo_color)

func _physics_process(delta):
	position.y -= velocidad * delta # Ajusta la dirección

func _on_area_entered(area): 
	print("La bala tocó a: ", area.name)
	# 1. Verificamos si el RigidBody tiene la función
	if area.has_method("recibir_proyectil"):
		print("La cubeta tiene el método, procediendo a llenar...")
		area.recibir_proyectil(id_dueno, sufijo_color)
		
		# 2. Lógica de la animación de impacto
		animar.play("chocar_proyectil" + sufijo_color)
		
		# 3. Desactivamos el proyectil para que no choque dos veces
		set_deferred("monitoring", false) 
		
		visible = false
		queue_free()
