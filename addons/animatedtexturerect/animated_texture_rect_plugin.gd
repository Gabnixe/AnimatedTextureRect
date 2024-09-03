@tool
extends EditorPlugin

func _enter_tree():
    add_custom_type("AnimatedTextureRect", "TextureRect", preload("animated_texture_rect.gd"), preload("icon.svg"))


func _exit_tree():
    remove_custom_type("AnimatedTextureRect")