# Extension of the Party class that is specific to playable characters
class_name EnemyParty extends Party

func character_scene_path():
	const character_path = "res://scenes/CharacterScenes/enemy_character.tscn"
	return preload(character_path).instantiate()
