extends SpinBox

func _on_value_changed(value:float):
	$"../../../AnimatedTextureRect".speed_scale = value
