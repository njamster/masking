extends VBoxContainer


var masks_depleted := 0


func add_mask() -> void:
	var icon = TextureRect.new()
	icon.texture = load("res://icon.svg")
	add_child(icon)


func deplete_mask() -> void:
	masks_depleted += 1

	get_child(-1 * masks_depleted).modulate.a = 0.2

	if masks_depleted == get_child_count():
		# TODO: game over
		get_tree().reload_current_scene()
		return  # early
