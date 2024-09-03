extends SpinBox

func _on_value_changed(_value:float):
	$"../../../AnimatedTextureRect".speed_scale = _value
