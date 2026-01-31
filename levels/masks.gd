extends VBoxContainer


var masks_depleted := 0


func add_mask() -> void:
	var icon = TextureRect.new()
	icon.texture = load("res://mask.png")
	add_child(icon)


func deplete_mask() -> void:
	masks_depleted += 1

	var depleted_mask := get_child(-1 * masks_depleted)
	depleted_mask.self_modulate.a = 0.0
	var particle_effect := preload("res://mask_depletion_particles.tscn").instantiate()
	particle_effect.position = 0.5 * depleted_mask.size
	particle_effect.emitting = true
	depleted_mask.add_child(particle_effect)


	if masks_depleted == get_child_count():
		# TODO: game over
		get_tree().reload_current_scene()
		return  # early
