class_name Party extends Node2D


@onready var cam = $PartyCamera
const MOVE_SPEED: float = 300.0
var party_members: Array[Character] = []
var movement_tween: Tween
#var party_pos_rect: Array[Rect2] = []
var selected_char: Character
var level: Level

func character_scene_path():
	const character_path = "res://scenes/CharacterScenes/character.tscn"
	return preload(character_path).instantiate()

func move_char(pos: Vector2i, map: Level) -> void:
	var tiles: TileMapLayer = map.find_child("Level") # TileMap containg room tiles
	var floor = map.ATLAS_IDs["floor"] # The Atlas id of floor tiles
	var tile_coord = tiles.local_to_map(tiles.to_local(pos)) # Coordinates of selected tile
	var tile_type = tiles.get_cell_source_id(tile_coord) # Atlas id of selected tile
	
	# If the selected tile is a floor tile move the character there
	if tile_type == floor:
		pos = pos.snappedi(16)
		selected_char.move_char(pos)

		print(selected_char.c_name," moved to: ", pos)
		cam.update_camera(party_members) # update camera

func select_character(c: Character):
	c.is_selected = true
	selected_char = c
	for char in party_members:
		if char != c:
			char.is_selected = false

# Add a new party member child: returns new Character object
func add_party_member() -> Character:
	# TODO: Add functionality to allow adding a CHOSEN character
	var new_member = self.character_scene_path()
	self.add_child(new_member)
	party_members.append(new_member)
	return new_member
