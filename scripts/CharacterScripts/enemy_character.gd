# An extension of the character class specific to enemy characters
class_name EnemyCharacter extends Character

# Called when character is loaded
func _ready() -> void:
	super()
	self.is_enemy = true

func run_turn(enemies: Array[Character]):
	# Run turn ai
	# TODO: THIS IS TERRIBLE, BARELY WORKS
	# Find closest enemy
	self.enemies = enemies
	var closest = enemies[0]
	for c in enemies:
		if (self.global_position - c.global_position).length() < (self.global_position - closest.global_position).length():
			closest = c
	var dest = closest.global_position - self.global_position
	dest.x += 16 if dest.x < 0 else -16
	#dest.y += 16 if dest.y < 0 else -16
	move_char(self.global_position + dest)
	
	## If there is an enemy in range attack it
	#if $Body/Sprite.animation == &"idle":
		#var characters_in_range: Array[Character]
		#for c in enemies:
			#if self.is_in_range(c):
				#characters_in_range.append(c)
		#
		#if !characters_in_range.is_empty():
			#while self.action_points > 0:
				#attack(characters_in_range.pick_random())
	#
		#end_turn.emit()
	pass


func _on_movement_stop() -> void:
	var characters_in_range: Array[Character]
	for c in self.enemies:
		if self.is_in_range(c):
			characters_in_range.append(c)
		
	if !characters_in_range.is_empty():
		while self.action_points > 0:
			attack(characters_in_range.pick_random())

		end_turn.emit()
	pass # Replace with function body.
