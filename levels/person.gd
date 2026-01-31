extends VBoxContainer


signal current_emotion_changed()

var time_left_tween

@onready var BUBBLE = $Bubble
@onready var DIALOG = BUBBLE.get_node("VBox/Dialog")
@onready var TIME_LEFT = BUBBLE.get_node("VBox/TimeLeft")

var current_emotion := "NEUTRAL":
	set(value):
		if current_emotion != value:
			current_emotion = value
			current_emotion_changed.emit()


func _ready() -> void:
	_set_initial_state()


func _set_initial_state() -> void:
	hide_bubble()
	DIALOG.text = ""
	TIME_LEFT.modulate.a = 0.0


func say(text: String, pre_delay: float, text_speed: float, post_delay: float) -> void:
	DIALOG.show()

	show_bubble()

	DIALOG.text = text

	DIALOG.visible_ratio = 0.0
	var tween := get_tree().create_tween()
	tween.tween_property(DIALOG, "visible_ratio", 1.0, text_speed).set_delay(pre_delay)


func show_bubble() -> void:
	BUBBLE.modulate.a = 1.0


func hide_bubble() -> void:
	BUBBLE.modulate.a = 0.0


func show_time_left(time: float) -> void:
	TIME_LEFT.value = 0.0
	TIME_LEFT.max_value = time

	TIME_LEFT.modulate.a = 1.0

	time_left_tween = create_tween()
	time_left_tween.tween_property(TIME_LEFT, "value", time, time)


func hide_time_left() -> void:
	TIME_LEFT.modulate.a = 0.0

	if time_left_tween:
		time_left_tween.kill()
