extends Label

func _on_frame_changed():
    set_text(str($"../../../AnimatedTextureRect".frame))
