extends Node2D
@onready var camara = $Camera2D 

func _ready() -> void:
	# 1. Obligamos al motor a usar ESTA cámara y apagar cualquier otra
	camara.make_current()
	
	# 2. Forzamos su posición al centro exacto del mundo (0,0)
	camara.global_position = Vector2.ZERO
	
	# (Aquí va el resto de tu código del _ready, como conectar las entradas)
