extends Camera2D
func _ready() -> void:
	# Me convierto en la cámara principal por la fuerza
	make_current()
	
	# Me aseguro de estar clavada en el 0,0
	global_position = Vector2.ZERO
