class_name Character extends Node2D

# Internal Variables
var to_pos: Vector2 		= Vector2.INF 	# Coordinate of desired movement location
var to_pos_slice: Vector2 	= Vector2.INF 	# Vector from self to to_pos
const MOVE_SPEED: float 	= 60			# Default character movement
var is_selected: bool		= false			# Is this character currently selected?

# Attributes
var max_health: float	= 20.0		# Maximum hitpoints of a character
var health: float		= 20.0		# Current hitpoints of a character
var speed: int			= 25		# Number of spaces a character may use on their turn
var is_magic: bool		= false		# Whether the character can use magic
var c_name: String		= "Henry"	# Character's name
var initiative: int		= 10		# Integer determining the turn order
var action_points: int	= 1			# Currency to spend on actions

# Modifiers
var equipment: Array[Equipment] = []	# Array containing equipped items
var phys_dmg_bonus: float = 0.0			# Flat damage modifier for physical damage
var mag_dmg_bonus: float = 0.0			# Flat damage modifier for magic damage
var phys_dmg_mult: float = 1.0			# Phyisical damage multiplier
var mag_dmg_mult: float = 1.0			# Magical damage multiplier

# Initialize class
func _init() -> void:
	# Initialize character and snap them to the tile grid
	self.position = self.position.snapped(Vector2(16, 16))
	#self.update_stats()

# Get global character position
func get_pos() -> Vector2:
	return $Body.global_position

# Returns the Rect2 bounding the sprite
func get_bounding_box() -> Rect2:
	return $Body/Collider.shape.get_rect()

# Returns the character body
func get_char() -> StaticBody2D:
	return $Body

# Returns the sprite
func get_sprite() -> AnimatedSprite2D:
	return $Body/Sprite

# Returns the collider
func get_collider() -> CollisionShape2D:
	return $Body/Collider

# Called when character is loaded
func _ready() -> void:
	$Body.motion_mode = 1 # Some jank that i forgot what it did, might work without this, but would require intensive testing
	$Body/Sprite.play("idle")
	$"Selection Indicator".play("default")
	self.update_stats()
	pass

# Declares character movement
func move_char(move_to: Vector2i) -> void:
	to_pos_slice = Vector2(move_to) - self.position
	# A vector pointing from current position to desired position
	to_pos = Vector2(move_to)
	# A vector pointing from the world origin to the desired point
	
	# Play moving animation and handle horizontal sprite flip
	$Body/Sprite.play("moving")
	if(to_pos_slice.x < 0):
		$Body/Sprite.flip_h = true
	else:
		$Body/Sprite.flip_h = false

# Update the character attribute panel
func update_stats():
	var w = "[color=white]"
	var text = w+"[b]"+c_name+"[/b]\n"
	text = text + str(w, health, "/", max_health, "[color=red] ♥\n")
	text = text + str(w, phys_dmg_bonus, "[color=red] Damage\n")
	if is_magic:
		text = text + str(w, mag_dmg_bonus, "[color=yellow] Magic Damage\n")
	text = text + str(w, action_points, "[color=cyan] AP\n")
	text = text + str(w, speed, "[color=green] Speed\n")
	text = text + str(w, initiative, "[color=orange] Initiative\n")
	$AttributePanel/PanelContainer/Attributes/RichTextLabel.text = text

# Called every tick
# Handles the visibility of the attribute panel
func _process(delta: float) -> void:
	# Display Stats if Mouse is hovered
	$AttributePanel.visible = self.get_collider().shape.get_rect().has_point(get_global_mouse_position() - self.get_char().global_position)
	$"Selection Indicator".visible = is_selected

# Called every physics tick
# Locks character to grid after movement
# Handles the frame by frame movement of character
func _physics_process(delta: float) -> void:
	
	# Snap character to tile grid when close to destination
	if (to_pos - self.position).length() <= 0.8:
		self.position = self.position.snapped(Vector2(16, 16))
		to_pos = Vector2.INF
		$Body/Sprite.play("idle")
	
	# Move Character incrementally and at a constant speed
	elif to_pos != Vector2.INF:
		var v = MOVE_SPEED * delta
		self.position = self.position + to_pos_slice.normalized() * v
