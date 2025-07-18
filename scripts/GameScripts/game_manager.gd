extends Node2D

signal game_over(victory_status) # Emits this signal when the game is lost or won
var turn_order: Array[Character] = []
var turn_idx: int = 0
var in_combat: bool = 0
var player_turn: bool = true
var char_turn: Character
var level: Level
@onready var player_party: PlayerParty = $PlayerParty
@onready var enemy_party: EnemyParty = $EnemyParty

func begin_combat():
	player_party.level = self.level
	enemy_party.level = self.level
	
	# Initiates a combat room
	for spt in level.get_spawns():
		var e: EnemyCharacter = enemy_party.add_party_member()
		e.c_name = "Evil Guy"
		e.initiative = 1
		e.global_position = spt.global_position
		e.update_stats()
	self.turn_order = enemy_party.party_members + player_party.party_members
	self.turn_order.sort_custom(func(a, b): return a.initiative > b.initiative)
	self.in_combat = true
	self.char_turn = turn_order[0]
	# If enemy run control logic
	if(self.char_turn.is_enemy): 
		self.player_turn = false
		enemy_party.select_character(self.char_turn)
		self.char_turn.run_turn(self.player_party.party_members)
	else: # If player let player begin turn
		self.player_turn = true
		player_party.select_character(self.char_turn)


func end_combat():
	self.turn_order = []
	self.in_combat = false
	self.level.combat = false
	self.player_turn = true
	for i in player_party.party_members:
		i.speed = i.max_speed
		i.action_points = i.max_ap

func load_room() -> void:
	# Loads the next room
	self.level = preload("res://scenes/level.tscn").instantiate()
	self.add_child(level)
	while !level.is_node_ready():
		pass
	if level.combat:
		begin_combat()

func get_party_cam() -> Camera2D:
	return player_party.cam

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_party.cam.position = Vector2(0.0, 0.0)
	player_party.cam.zoom = Vector2(5.0, 5.0)
	load_room()
	player_party.level = level # This is bad practice, when level is needed in party script it should be passed via function
	# player_party.add_party_member()

# Returns a character if one exists at the position, otherwise retuns null
func char_at(pos: Vector2) -> Character:
	var c: Character = null
	for i in self.enemy_party.party_members:
		if i.global_position.is_equal_approx(pos):
			c = i
	for i in self.player_party.party_members:
		if i.global_position.is_equal_approx(pos):
			c = i
	return c

# Input handler
func event_handler(event: InputEvent) -> void:
	var event_pos = get_local_mouse_position() # Mouse position at time of event
	
	# Input logic for non-combative rooms
	if !level.combat:
		# Select button press
		if event.is_action_pressed("select"):
			# Select new member if clicking on a character
			for member in player_party.party_members:
				# Check which party member has been clicked on
				if member.get_collider().shape.get_rect().has_point(event_pos - member.get_char().global_position):
					print("Selected Character: ", member.c_name)
					player_party.select_character(member)
					return
			# Move character to new location if not selecting character
			if player_party.selected_char:
				player_party.move_char(event_pos, level, self.in_combat)
		
		# Deselect button press
		if event.is_action_pressed("deselect"):
			player_party.selected_char.is_selected = false
			player_party.selected_char = null
	
	# Input logic for combatitve rooms
	else:
		if self.player_turn:
			# Select button press
			if event.is_action_pressed("select"):
				var target = char_at(event_pos.snapped(Vector2(16, 16)))
				if target == null:
					self.player_party.move_char(event_pos, level, self.in_combat)
				else:
					if target in enemy_party.party_members:
						char_turn.attack(target)
			# Deselect button press
			if event.is_action_pressed("deselect"):
				end_turn()

# Resets characters AP, speed and increments turn counter
func end_turn():
	# Handle turn over
	self.char_turn.speed = self.char_turn.max_speed # Reset speed
	self.char_turn.action_points += self.char_turn.ap_regen # Regen action points
	if self.char_turn.action_points > self.char_turn.max_ap: # If over max AP drop to max
		self.char_turn.action_points = self.char_turn.max_ap
	self.char_turn.update_stats() # Update attribite context box
	
	# Update turn order
	self.turn_idx += 1
	self.turn_idx %= len(self.turn_order)
	for i in turn_order: # Set all characters to be deselected
		i.is_selected = false
		self.enemy_party.selected_char = null
		self.player_party.selected_char = null
	self.char_turn = self.turn_order[turn_idx] # Select the next character in turn order
	
	# If enemy run control logic
	if(self.char_turn.is_enemy): 
		self.player_turn = false
		enemy_party.select_character(self.char_turn)
		self.char_turn.run_turn(self.player_party.party_members)
	else: # If player let player begin turn
		self.player_turn = true
		player_party.select_character(self.char_turn)

func _input(event: InputEvent) -> void:
	event_handler(event)
	# This code is redundant

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(self.in_combat && self.player_turn):
		if self.char_turn == null:
			return
			
				#self.char_in_range = []
				#for c in self.turn_order:
					#if c in self.enemy_party.party_members:
						#self.char_in_range.append(c)
				#
				#modulate_in_range_tint(100,1,1,30)
				
		for c in turn_order:
			if char_turn.is_in_range(c) && c not in player_party.party_members:
				c.add_tint(100, 1, 1)
			else: c.add_tint(1, 1, 1)
	if !self.player_turn:
		self.char_turn.run_turn(self.player_party.party_members)
	pass

# Check if either player or enemies won
func check_loss():
	if player_party.party_members.is_empty():
		end_combat()
		game_over.emit(false)
	if enemy_party.party_members.is_empty():
		end_combat()

# Run this when a character emits their death signal
func _on_character_death(c) -> void:
	if turn_idx > turn_order.find(c):
		turn_idx -= 1
	if c in turn_order:
		turn_order.erase(c)
	if c in enemy_party.party_members:
		enemy_party.party_members.erase(c)
		enemy_party.remove_child(c)
	if c in player_party.party_members:
		player_party.party_members.erase(c)
		player_party.remove_child(c)
	c.queue_free()
	check_loss()

# Connect to a player character death signal and turn signal
func _on_player_party_char_added(c) -> void:
	c.death.connect(_on_character_death)
	c.end_turn.connect(end_turn)
	pass # Replace with function body.
# Connect to an enemy character death signal and turn signal
func _on_enemy_party_char_added(c) -> void:
	c.death.connect(_on_character_death)
	c.end_turn.connect(end_turn)
	pass # Replace with function body.
