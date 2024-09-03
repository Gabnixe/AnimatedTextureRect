#Else, it caused problem when playing the animation in editor, since the label could receive the signal
@tool
extends Label

func _on_frame_changed():
    set_text(str($"../../../AnimatedTextureRect".frame))
