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

# Level Attributes
var combat: bool = true 		# Determines if this room is a combat room
var boss: bool = false			# Determines if this room is a boss room
# TODO: Much to be done here maybe

# Creates enemy at pos
func create_enemy(pos: Vector2) -> void:
	var enemy = $EnemyParty.add_party_member()
	enemy.global_position = pos
	enemy.c_name = "EVIL GUY"
	var s = enemy.ready
	var spr = enemy.get_sprite()
	pass
	
	

# Spawns enemies, creates enemy party
func _ready() -> void:
	if self.combat:
		# play combat music
		for spawn in $Spawns.get_children(): # Spawn enemies
			create_enemy(spawn.global_position)
