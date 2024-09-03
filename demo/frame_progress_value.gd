extends Label

# Dirty but work as a demo
func _process(_delta: float):
    set_text(str($"../../../AnimatedTextureRect".frame_progress))
