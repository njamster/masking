extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_released():
		match event.keycode:
			KEY_R:
				get_tree().reload_current_scene()
			KEY_P:
				get_tree().paused = not get_tree().paused
