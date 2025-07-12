extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Party/PartyCamera.position = Vector2(0.0, 0.0)
	$Party/PartyCamera.zoom = Vector2(5.0, 5.0)
	$Party.level = $Level # This is bad practice, when level is needed in party script it should be passed via function

# Input handler
func event_handler(event: InputEvent) -> void:
	var event_pos = get_local_mouse_position() # Mouse position at time of event
	
	# Select button press
	if	event.is_action_pressed("select"):
		# Select new member if clicking on a character
		for member in $Party.party_members:
			# Check which party member has been clicked on
			if member.get_collider().shape.get_rect().has_point(event_pos - member.get_char().global_position):
				print("Selected Character: ", member.c_name)
				$Party.select_character(member)
				return
		# Move character to new location if not selecting character
		if $Party.selected_char:
			$Party.move_char(event_pos, $Level)
	
	# Deselect button press
	if event.is_action_pressed("deselect"):
		$Party.selected_char.is_selected = false
		$Party.selected_char = null
			
func _input(event: InputEvent) -> void:
	event_handler(event)
	# This code is redundant


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
