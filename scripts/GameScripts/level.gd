class_name Level extends Node2D

# Texture Locations
const ATLAS_DICT: Dictionary = {
	"unfilled": [Vector2i(8,7)],
	"top_wall": [Vector2i(1,0)],
	"left_wall": [Vector2i(0,0)],
	"right_wall": [Vector2i(5,0)],
	"bottom_wall": [Vector2i(1,4)],
	"b_left_wall": [Vector2i(0,4)],
	"b_right_wall": [Vector2i(5,4)],
	"floor": [Vector2i(2,2)]
}
# Texture Source Ids
const ATLAS_IDs: Dictionary = {
	"unfilled": -1,
	"wall": 2,
	"floor": 1
}
# Associated numbers with their location dictionary keys
const NUM_TO_ATLAS: Dictionary = {
	0: "unfilled",
	1: "top_wall",  
	2: "left_wall",  
	3: "right_wall",  
	4: "bottom_wall",  
	5: "b_left_wall",  
	6: "b_right_wall",  
	7: "floor" 
}

const ID_TO_NAME: Array[String] = ["", "floor", "wall"]

# Level Attributes
var combat: bool = true 		# Determines if this room is a combat room
var boss: bool = false			# Determines if this room is a boss room
var difficulty: int = 0			# Level difficulty
# TODO: Much to be done here maybe

func get_tile(pos: Vector2) -> String:
	var tiles: TileMapLayer = $Level # TileMap containg room tiles
	var tile_coord = tiles.local_to_map(tiles.to_local(pos)) # Coordinates of selected tile
	var tile_type = tiles.get_cell_source_id(tile_coord) # Atlas id of selected tile
	return ID_TO_NAME[tile_type]

func get_spawns() -> Array[Node]:
	return $Spawns.get_children()
