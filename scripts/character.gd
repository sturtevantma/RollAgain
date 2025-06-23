class_name Character extends Node2D

# Internal Variables
var to_pos: Vector2 			= Vector2.INF 	# Coordinate of desired movement location
var to_pos_slice: Vector2 	= Vector2.INF 	# Vector from self to to_pos
const MOVE_SPEED: float 		= 60				# Default character movement
var is_selected: bool		= false			# Is this character currently selected?

# Attributes
var health: float		= 20.0
var speed: int			= 25
var dmg_bonus: float 	= 0.0
var is_magic: bool		= false
var c_name: String		= "Henry"


func _init() -> void:
	# Initialize character and snap them to the tile grid
	self.position = self.position.snapped(Vector2(16, 16))

func get_pos() -> Vector2:
	return $Body.global_position

func get_bounding_box() -> Rect2:
	return $Body/Collider.shape.get_rect()

func get_char() -> StaticBody2D:
	return $Body

func get_sprite() -> AnimatedSprite2D:
	return $Body/Sprite

func get_collider() -> CollisionShape2D:
	return $Body/Collider

func _ready() -> void:
	$Body.motion_mode = 1 # Some jank that i forgot what it did, might work without this, but would require intensive testing
	pass
	
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

func _process(delta: float) -> void:
	$Body/Sprite2D.visible = is_selected

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
