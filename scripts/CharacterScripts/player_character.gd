# An extension of the character class specific to player characters
class_name PlayerCharacter extends Character

# Overwrite stats functionality
func update_stats():
# Write attribute stats to the attribute panel
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
