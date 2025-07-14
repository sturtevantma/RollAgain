extends CollisionShape2D

# Creates a collider at the mouse point
# CURRENTLY UNUSED
# REDUNDANT
func _process(delta: float) -> void:
	self.position = get_global_mouse_position()
	pass
