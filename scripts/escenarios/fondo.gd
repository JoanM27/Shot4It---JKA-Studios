extends ParallaxBackground
# Velocidad a la que se mueve el fondo (Y positivo hace que el fondo baje, 
# dando la ilusión de que la nave y la cámara suben)
@export var velocidad_scroll: Vector2 = Vector2(0, 50) 

func _process(delta: float) -> void:
	# Modificamos directamente el offset interno del fondo
	scroll_base_offset += velocidad_scroll * delta
