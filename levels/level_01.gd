extends Control

const PRE_LINE_DELAY := 0.5  # seconds
const POST_LINE_DELAY := 1.5  # seconds

@export var chars_per_second = 15

var mask_count

var dialog_data
var replies

var current_line_id := -1
var target_emotion := ""


func _enter_tree() -> void:
	_load_dialog_data("res://levels/dialog.json")


func _load_dialog_data(path: String):
	# read the files content…
	var file := FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	# … and parse it as JSON
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		mask_count = json.data["mask_count"]
		replies = json.data["replies"]
		dialog_data = json.data["dialog"]


func _ready() -> void:
	_connect_signals()
	_play_level_intro()


func _connect_signals() -> void:
	$WaitTime.timeout.connect(func():
		if target_emotion and %Player.current_emotion != target_emotion:
			load_reply(%Player.current_emotion)
		else:
			load_next_line()
	)
	%Player.current_emotion_changed.connect(func():
		if target_emotion and %Player.current_emotion == target_emotion:
			load_next_line()
	)


func _play_level_intro() -> void:
	# wait one frame (so we can change the position)
	await get_tree().process_frame

	$%Opponent.position.x += 1000

	var tween = get_tree().create_tween()
	tween.tween_property($%Opponent, "position:x", -1000, 1.0).as_relative()
	await tween.finished

	for i in range(mask_count):
		$Masks.add_mask()
		await get_tree().create_timer(0.2).timeout

	load_next_line()


func load_next_line() -> void:
	target_emotion = ""
	$WaitTime.stop()

	if current_line_id == dialog_data.size() - 1:
		%Opponent.hide_bubble()
		%Player.hide_bubble()
		# TODO: Level won!
		get_tree().reload_current_scene()
		return  # early

	current_line_id += 1

	var data = dialog_data[current_line_id]

	var is_player: bool = data.has("is_player") and data.is_player

	if data.has("displayed_emotion"):
		if is_player:
			%Player/Face.set_emotion(data["displayed_emotion"])
		else:
			%Opponent/Face.set_emotion(data["displayed_emotion"])

	if data.has("text"):
		var text_speed = data.text.length() / chars_per_second

		if is_player:
			%Player.say(data.text, PRE_LINE_DELAY, text_speed, POST_LINE_DELAY)
			%Opponent.hide_bubble()
		else:
			%Opponent.say(data.text, PRE_LINE_DELAY, text_speed, POST_LINE_DELAY)
			%Player.hide_bubble()

		await get_tree().create_timer(PRE_LINE_DELAY + text_speed).timeout

	if data.has("target_emotion") and %Player.current_emotion != data["target_emotion"]:
		target_emotion = data["target_emotion"]

	if data.has("wait_time"):
		$WaitTime.wait_time = data["wait_time"]
		$WaitTime.start()
		if target_emotion:
			%Opponent.show_time_left(data["wait_time"])
		return  # early

	await get_tree().create_timer(POST_LINE_DELAY).timeout

	if target_emotion == "":
		load_next_line()


func load_reply(emotion: String) -> void:
	%Opponent.hide_time_left()
	var text = replies[emotion][randi() % replies[emotion].size()]
	var text_speed = text.length() / chars_per_second
	%Opponent.say(text, PRE_LINE_DELAY, text_speed, POST_LINE_DELAY)
	$Masks.deplete_mask()
	await get_tree().create_timer(PRE_LINE_DELAY + text_speed + POST_LINE_DELAY).timeout
	load_next_line()
