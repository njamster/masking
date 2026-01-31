extends TextureRect


const EYES_HAPPY = preload("res://face/images/eyes_happy.png")
const EYES_NEUTRAL = preload("res://face/images/eyes_neutral.png")
const EYES_SAD = preload("res://face/images/eyes_sad.png")

const MOUTH_HAPPY = preload("res://face/images/mouth_happy.png")
const MOUTH_NEUTRAL = preload("res://face/images/mouth_neutral.png")
const MOUTH_SAD = preload("res://face/images/mouth_sad.png")

@export var is_player := false


func _ready() -> void:
	if not is_player:
		$ChangeEyes.queue_free()
		$ChangeMouth.queue_free()

	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	$Eyes.texture = EYES_HAPPY
	$Mouth.texture = MOUTH_HAPPY


func _connect_signals() -> void:
	$ChangeEyes.pressed.connect(_change_eyes)
	$ChangeMouth.pressed.connect(_change_mouth)


func _change_eyes() -> void:
	match $Eyes.texture:
		EYES_HAPPY:
			$Eyes.texture = EYES_NEUTRAL
		EYES_NEUTRAL:
			$Eyes.texture = EYES_SAD
		EYES_SAD:
			$Eyes.texture = EYES_HAPPY
	$ChangeMouth.pressed.connect(_change_mouth)


func _change_mouth() -> void:
	match $Mouth.texture:
		MOUTH_HAPPY:
			$Mouth.texture = MOUTH_NEUTRAL
		MOUTH_NEUTRAL:
			$Mouth.texture = MOUTH_SAD
		MOUTH_SAD:
			$Mouth.texture = MOUTH_HAPPY
