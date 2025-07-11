class_name PartyManager extends Node2D


@onready var cam = $PartyCamera
const MOVE_SPEED: float = 300.0
var party_members: Array[Character] = []
var movement_tween: Tween
#var party_pos_rect: Array[Rect2] = []
var selected_char: Character
var level: Level

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


func add_party_member() -> Character:
# Add a new party member child: returns new Character object
	var new_member = preload("res://scenes/character.tscn").instantiate()
	self.add_child(new_member)
	party_members.append(new_member)
	return new_member

func _process(delta: float) -> void:
	cam.update_camera(party_members)
	
	

func _ready() -> void:
	
	# FOR TESTING PURPOSES
	add_party_member()
	var b = add_party_member()
	b.c_name = "Steve"
	b.is_magic = true
	b.position = Vector2i(32, 32)
	b.update_stats()
