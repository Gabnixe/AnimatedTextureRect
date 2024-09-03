@tool
extends Node

const WALL_VARIATIONS = {
	"Dungeon": [
		"Dungeon variation 1",
		"Dungeon variation 2",
		"Dungeon variation 3",
	],
	"House": [
		"House variation 1",
		"House variation 2",
	],
	"Castle": [
		"Castle variation 1",
		"Castle variation 2",
		"Castle variation 3",
		"Castle variation 4",
	]
}

var wall_type:String = "Dungeon":
	set(value):
		if not value == wall_type:
			variation = WALL_VARIATIONS.get(value, []).front()
			notify_property_list_changed()
		wall_type = value

var variation:String = ""


func _get_property_list() -> Array[Dictionary]:
	var properties:Array[Dictionary] = []

	properties.push_back({
		"name": "wall_type",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(WALL_VARIATIONS.keys()),
		"usage": PROPERTY_USAGE_DEFAULT
	})

	var variations = WALL_VARIATIONS.get(wall_type, [])
	if not variations.is_empty():
		properties.push_back({
			"name": "variation",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(variations),
			"usage": PROPERTY_USAGE_DEFAULT
		})

	return properties