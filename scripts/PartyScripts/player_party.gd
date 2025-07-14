# Extension of the Party class that is specific to playable characters
class_name PlayerParty extends Party

func character_scene_path():
	const character_path = "res://scenes/CharacterScenes/player_character.tscn"
	return preload(character_path).instantiate()

# Updates the camera based on player locations
# TODO: Explore a room camera instead
func _process(delta: float) -> void:
	cam.update_camera(party_members)

func _ready() -> void:
	
#	 FOR TESTING PURPOSES
	add_party_member()
	var b = add_party_member()
	b.c_name = "Steve"
	b.is_magic = true
	b.position = Vector2i(32, 32)
	b.update_stats()
	pass
