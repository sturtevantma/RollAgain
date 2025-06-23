extends Camera2D

# TODO:
# Explore a static "room camera" option


const ZOOM: float = 1.5
const MIN_ZOOM: float = 5

func get_average_party_position(chars: Array[Character]) -> Vector2:
	# Calculate everage character position
	var avg_pos: Vector2
	for character in chars:
		avg_pos.x += character.get_pos().x
		avg_pos.y += character.get_pos().y
	avg_pos.x /= len(chars)
	avg_pos.y /= len(chars)
	return avg_pos
	
func zoom_to_fit(chars: Array[Character]) -> float:
	# Determine zoom
	var max_dist: float = 0.0
	for p1 in chars:
		for p2 in chars:
			if (p1.get_pos() - p2.get_pos()).length() > max_dist:
				max_dist = (p1.get_pos()-p2.get_pos()).length()
	return ((max_dist / get_viewport_rect().size.x) * ZOOM) * 0.25
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update_camera(party_members: Array[Character]) -> void:
	
	var cam_pos: Vector2 = get_average_party_position(party_members)
	var cam_zoom: float = zoom_to_fit(party_members)
	
	self.position = cam_pos
	if cam_zoom > MIN_ZOOM:
		self.zoom = Vector2(cam_zoom, cam_zoom)
	else:
		self.zoom = Vector2(MIN_ZOOM, MIN_ZOOM)
	pass
