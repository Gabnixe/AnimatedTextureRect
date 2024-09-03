#Made by Gabnixe

#A GDScript implemention of an equivalent of AnimatedSprite2D for TextureRect
#Check AnimatedSprite2D docs for more info on public signals, properties and functions

#Every scripts that extends this one need to also have a @tool tag for the in-editor functions to work properly
@tool
extends TextureRect

class_name AnimatedTextureRect

#Signals shared with AnimatedSprite2D
signal animation_changed()
signal animation_finished()
signal animation_looped()
signal frame_changed()
signal sprite_frames_changed()

#AnimatedTextureRect specific properties
@export_group("SpriteFrames Dock Replacement")
@export var show_preview : bool = false
@export var autoplay : bool = true

#Properties shared with AnimatedSprite2D
@export_group("Animation")
@export var sprite_frames : SpriteFrames : set = _set_sprite_frames
#Technically @export, check _get_property_list for more details
var animation: String : set = _set_animation
@export var frame : int : set = _set_frame
@export var speed_scale : float = 1.0

var frame_progress : float

#Private properties
var _playing : bool = false
var _custom_speed : float = 1.0

func get_playing_speed():
    return speed_scale * _custom_speed

func is_playing():
    if Engine.is_editor_hint():
        return show_preview
    else:
        return _playing

func pause():
    _playing = false
    pass

#Calling Play() without parameters will start/resume the currently selected animation
func play(name: StringName = &"", custom_speed: float = 1.0, from_end: bool = false):
    if name != &"":
        animation = name
        _custom_speed = custom_speed
        if from_end:
            frame = sprite_frames.get_frame_count(animation) - 1
    _playing = true


func play_backwards(name: StringName = &""):
    play(name, -1.0, true)

func set_frame_and_progress(new_frame: int, new_progress: float):
    frame = new_frame
    frame_progress = new_progress
    pass

func stop():
    pause()
    frame = 0
    _custom_speed = 1
    pass

func _ready() -> void:
    if sprite_frames:
        if autoplay: 
            if sprite_frames.has_animation(animation):
                play()
        _set_sprite_frames(sprite_frames)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float): 
    if is_playing():
        if sprite_frames:
            if sprite_frames.has_animation(animation):
                var time_since_last_frame = delta * abs(get_playing_speed())
                var frame_lenght = 1/sprite_frames.get_animation_speed(animation)
                var frame_progress_since_last_frame = time_since_last_frame / frame_lenght
                frame_progress = frame_progress + frame_progress_since_last_frame
                if frame_progress > 1:
                    var new_frame : int
                    if get_playing_speed() > 0:
                        new_frame = frame + int(frame_progress)
                    else:
                        new_frame = frame - int(frame_progress)
                    var new_frame_progress = frame_progress - int(frame_progress)
                    set_frame_and_progress(new_frame, new_frame_progress)
            else:
                push_warning("Trying to play animation with an invalid animation set")
        else:
            push_warning("Trying to play animation with no SpriteFrames set")

func _set_sprite_frames(value : SpriteFrames):
    #Disconnect from old sprite_frames
    if sprite_frames:
        sprite_frames.changed.disconnect(_on_sprite_frames_changed)
    sprite_frames = value
    if sprite_frames == null:
        stop()
        texture = null
        show_preview = false
    else:
        #Set a default animation
        animation = sprite_frames.get_animation_names()[0]
        value.changed.connect(_on_sprite_frames_changed)
    _on_sprite_frames_changed()

func _on_sprite_frames_changed():
    #Update properties list to update available animation list
    sprite_frames_changed.emit()
    notify_property_list_changed()


func _set_frame(value : int):
    if sprite_frames:
        if animation:
            var frame_count = sprite_frames.get_frame_count(animation)
            if sprite_frames.get_animation_loop(animation):
                if value >= frame_count:
                    frame = value % frame_count
                    animation_looped.emit()
                elif value < 0:
                    frame = frame_count + (value % frame_count) - 1
                    animation_looped.emit()
                else:
                    frame = value
            else:
                if value >= frame_count or value < 0:
                    frame = clamp(value, 0, frame_count - 1)
                    animation_finished.emit()
                    pause()
                else:
                    frame = value
            texture = sprite_frames.get_frame_texture(animation, frame)
        else:
            push_warning("Trying to change frame with no valid animation set")
            frame = 0
    else:
        push_warning("Trying to change frame with no SpriteFrames set")
        frame = 0
    frame_progress = 0
    frame_changed.emit()


func _set_animation(value : String):
    if sprite_frames:
        if sprite_frames.has_animation(value):
            animation = value
            #Reset frame since we changed animation
            frame = 0
            if autoplay and !Engine.is_editor_hint(): 
                play()
        else:
            push_warning("Trying to change animation to an invalid one")
            animation = ""
    else:
        push_warning("Trying to change animation with no SpriteFrames set")
        animation = ""
    animation_changed.emit()

#Add animation propriety according to the animations in the spriteframes ressource
func _get_property_list():
    var properties:Array[Dictionary] = []
    if sprite_frames:
        var animations = sprite_frames.get_animation_names()
        properties.push_front({
            "name": "animation",
            "type": TYPE_STRING,
            "hint": PROPERTY_HINT_ENUM,
            "hint_string": ",".join(animations),
            "usage": PROPERTY_USAGE_DEFAULT
        })
    else:
        properties.push_front({
            "name": "animation",
            "type": TYPE_STRING,
            "hint": PROPERTY_HINT_ENUM,
            "hint_string": "",
            "usage": PROPERTY_USAGE_DEFAULT
        })

    return properties
