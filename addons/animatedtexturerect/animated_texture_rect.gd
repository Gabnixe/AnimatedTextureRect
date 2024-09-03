@tool
extends TextureRect

class_name AnimatedTextureRect

signal animation_changed()
signal animation_finished()
signal animation_looped()
signal frame_changed()
signal sprite_frames_changed()

@export_group("Animation")
@export var sprite_frames : SpriteFrames : set = _set_sprite_frames
var animation: String : set = _set_animation
@export var frame : int : set = _set_frame
@export var speed_scale : float = 1.0
@export var show_preview : bool = false

var frame_progress : float

#Private
var _playing : bool = false
var _custom_speed : float = 1.0

func get_playing_speed():
	return speed_scale * _custom_speed

func is_playing():
	if Engine.is_editor_hint() and show_preview:
		return true
	else:
		return _playing

func pause():
	_playing = false
	pass

func play(name: StringName = &"", custom_speed: float = 1.0, from_end: bool = false):
	animation = name
	_custom_speed = custom_speed
	if from_end:
		frame = sprite_frames.get_frame_count(animation) - 1
	pass
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
		_set_sprite_frames(sprite_frames)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float): 
	if is_playing():
		if sprite_frames:
			frame_progress = frame_progress + (delta * abs(get_playing_speed())) 
			var frame_lenght = 1/sprite_frames.get_animation_speed(animation)
			var nb_frames_till_last_update = frame_progress / frame_lenght
			if nb_frames_till_last_update > 1:
				var new_frame : int
				if get_playing_speed() > 0:
					new_frame = frame + int(nb_frames_till_last_update)
				else:
					new_frame = frame - int(nb_frames_till_last_update)
				var new_frame_progress = frame_progress - (nb_frames_till_last_update * frame_lenght)
				set_frame_and_progress(new_frame, new_frame_progress)
		else:
			push_warning("Trying to play animation with no SpriteFrames set")

func _set_sprite_frames(value : SpriteFrames):
	if sprite_frames:
		sprite_frames.changed.disconnect(_update_data)
	sprite_frames = value
	if sprite_frames == null:
		stop()
		texture = null;
		show_preview = false
	else:
		value.changed.connect(_update_data)
		_update_data()
	sprite_frames = value
	#Update properties list to update available animation list
	notify_property_list_changed()

func _update_data():
	if sprite_frames:
		frame_progress = 0
		frame = 0
		notify_property_list_changed()


func _set_frame(value : int):
	if sprite_frames:
		if animation:
			var frame_count = sprite_frames.get_frame_count(animation)
			if value >= frame_count:
				frame = value - frame_count
			elif value < 0:
				frame = frame_count + value
			else:
				frame = value
			texture = sprite_frames.get_frame_texture(animation, frame)
		else:
			push_warning("Trying to change active frame with no valid animation set")
			frame = 0
	else:
		push_warning("Trying to change active frame with no SpriteFrames set")
		frame = 0
	frame_progress = 0

func _set_animation(value : String):
	if sprite_frames:
		if sprite_frames.has_animation(value):
			animation = value
			#Reset frame since we changed animation
			frame_progress = 0
			frame = 0

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