extends Control

const CONVERSATION_DELAY := 0.5  # seconds
const PRE_LINE_DELAY := 0.5  # seconds
const POST_LINE_DELAY := 1.5  # seconds

@export var chars_per_second = 8

var dialog_data
var interrupts

var mask_count

var current_line_id := -1


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
		dialog_data = json.data["main"]
		interrupts = json.data["interrupts"]

		mask_count = json.data["mask_count"]


func _ready() -> void:
	_play_level_intro()


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

	await get_tree().create_timer(CONVERSATION_DELAY).timeout

	load_next_line()


func load_next_line() -> void:
	if current_line_id == dialog_data.size() - 1:
		%Opponent.hide_bubble()
		%Player.hide_bubble()
		# TODO: Level won!
		get_tree().reload_current_scene()
		return  # early

	current_line_id += 1

	var data = dialog_data[current_line_id]
	var text_speed = data.text.length() / chars_per_second

	if data.has("is_player") and data.is_player:
		%Player.say(data.text, PRE_LINE_DELAY, text_speed, POST_LINE_DELAY)
		%Opponent.hide_bubble()
	else:
		%Opponent.say(data.text, PRE_LINE_DELAY, text_speed, POST_LINE_DELAY)
		%Player.hide_bubble()

	await get_tree().create_timer(PRE_LINE_DELAY + text_speed + POST_LINE_DELAY).timeout
	load_next_line()
