class_name Character extends Node2D

# Signals
signal death(char)
signal movement_stop()
signal end_turn()

# Internal Variables
var to_pos: Vector2 				= Vector2.INF 	# Coordinate of desired movement location
var to_pos_slice: Vector2 		= Vector2.INF 	# Vector from self to to_pos
const MOVE_SPEED: float 			= 60			# Default character movement
var is_selected: bool			= false			# Is this character currently selected?
var is_enemy: bool				= false
var enemies: Array[Character]	= []

# Attributes
var max_health: float	= 20.0		# Maximum hitpoints of a character
var health: float		= 20.0		# Current hitpoints of a character
var max_speed: int		= 5			# Maximum number of spaces a character may move on their turn
var speed: int			= 5			# Number of spaces a character has of remaining movement
var is_magic: bool		= false		# Whether the character can use magic
var c_name: String		= "Henry"	# Character's name
var initiative: int		= 10			# Integer determining the turn order
var ap_regen: int		= 1			# Amount of AP regenerated at end of turn
var max_ap: int			= 1			# Maximum AP that can be alotted to self
var action_points: int	= 1			# Currency to spend on actions
var range: int			= 1			# The maximum of tiles away a character can be to be hit

# Modifiers
var equipment: Array[Equipment] = []	# Array containing equipped items
var phys_dmg_bonus: float = 0.0			# Flat damage modifier for physical damage
var mag_dmg_bonus: float = 0.0			# Flat damage modifier for magic damage
var phys_dmg_mult: float = 1.0			# Phyisical damage multiplier
var mag_dmg_mult: float = 1.0			# Magical damage multiplier
var phys_dmg_reduc: float = 0			# Resistance amount to physical damage
var mag_dmg_reduc: float = 0			# Resistance amount to magical damage

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
	self.update_stats()

# Update the character attribute panel
func update_stats():
	var w = "[color=white]"
	var text = w+"[b]"+c_name+"[/b]\n"
	text = text + str(w, health, "/", max_health, "[color=red] ♥\n")
	$AttributePanel/PanelContainer/Attributes/RichTextLabel.text = text

# A function to attack an enemy
func attack(target: Character):
	if action_points >= 1:
		self.action_points -= 1
		var rng = RandomNumberGenerator.new()
		var dmg = rng.randi_range(1,6)
		target.add_damage(dmg + self.phys_dmg_bonus, false)
	self.update_stats()

# A function do deal damage to self
func add_damage(dmg: int, mag_dmg: bool):
	if mag_dmg:
		self.health -= dmg * (1 - self.mag_dmg_reduc)
	else:
		self.health -= dmg * (1 - self.phys_dmg_reduc)
	self.update_stats()
	#if self.health <= 0:
		#self.kill_self()

func add_tint(r: int, g: int, b: int):
	var spr = self.get_sprite()
	spr.modulate.a = 1
	spr.modulate.r = r
	spr.modulate.g = g
	spr.modulate.b = b

func is_in_range(c: Character) -> bool:
	return abs(c.global_position - self.global_position).length() <= 8 + 16 * self.range

func run_turn(enemies: Array[Character]):
	pass

# Called every tick
# Handles the visibility of the attribute panel
func _process(delta: float) -> void:
	# Display Stats if Mouse is hovered
	if self.health <= 0:
		$Body/Sprite.play("death")
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
		movement_stop.emit()
		$Body/Sprite.play("idle")
	
	# Move Character incrementally and at a constant speed
	elif to_pos != Vector2.INF:
		var v = MOVE_SPEED * delta
		self.position = self.position + to_pos_slice.normalized() * v


func _on_sprite_animation_looped() -> void:
	if $Body/Sprite.animation == &"death":
		death.emit(self)
		self.visible = false
		
