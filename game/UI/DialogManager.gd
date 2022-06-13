extends Control

var _dialog: Array
var _current_dialog: int = 0

func add_text(txt: String) -> void:
	$DilaogWindow/DialogBackground/Dialog.text = txt


func add_dialog(json: Array) -> void:
	_dialog = json
	run_dialog()


func close_dialog() -> void:
	hide()
	#NOTE: Let the Gamestate close the dialog to ensure other processes are completed
	Gamestate.close_dialog()


func run_dialog() -> void:
	_current_dialog = 0
	add_text(_dialog[_current_dialog].text)


func _next() -> void:
	_current_dialog += 1
	if _current_dialog < _dialog.size():
		add_text(_dialog[_current_dialog].text)
	else:
		close_dialog()


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("use"):
		print("Use action is pressed")
		_next()
