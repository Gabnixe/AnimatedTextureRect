# Animated Texture Rect

A GDScript implemention of an equivalent of AnimatedSprite2D for TextureRect, to display SpriteFrames in your UI

> This plugin was only tested with **Godot 4.x**

## Features

- Self-contained
  - Only one script needed (addons/animatedtexturerect/animated_texture_rect.gd)
- Seamless integration
  - Implements most of the features of AnimatedSprite2D 

## Installation

  Download this repository, move `addons` to your `{project_dir}`

## Known Limitations

- Does not open the current SpriteFrames of the selected AnimatedTextureRect in a dock, like AnimatedSprites2D does
  - 2 parameters have been added to have similar functionnalities (Autoplay and ShowPreview)
- Being written in GDScript, this may not be the most performant implementation, but good enough for a few animated elements in your UI
