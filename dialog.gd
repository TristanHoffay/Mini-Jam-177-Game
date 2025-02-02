class_name Dialog extends Node2D
@onready var dialog_text = $Sprite2D/DialogText
@export var text_to_show : String
@export var frames_per_char: int = 3
var chars_shown : int
var frames_until_next_char: int = 0

func set_text(text: String):
	chars_shown = 0
	text_to_show = text

func add_line(text: String):
	text_to_show += '\n' + text

func _process(delta):
	if chars_shown < text_to_show.length()+1:
		if frames_until_next_char <= 0:
			dialog_text.text = text_to_show.substr(0,chars_shown)
			chars_shown += 1
			frames_until_next_char = frames_per_char-1
		else:
			frames_until_next_char -= 1
	var lines = dialog_text.get_line_count()
	if lines > 3:
		dialog_text.lines_skipped = dialog_text.get_line_count()-3
	else:
		dialog_text.lines_skipped = 0
