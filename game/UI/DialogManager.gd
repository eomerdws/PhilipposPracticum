extends Control

var _dialog: Array
var _current_dialog: int = 0

"""
_dialog is expected to be an array of JSON objects that appear as:
{
	"texture": String
	"text": String
	"animation": String
	"trigger": String
}
"""


func add_text() -> void:
	$DilaogWindow/DialogBackground/Dialog.text = _dialog[_current_dialog].text


func add_portrait() -> void:
	if _dialog[_current_dialog].texture:
		$CharacterPortrait.texture = load("res://assets/actors/portraits/" + _dialog[_current_dialog].texture)
		$CharacterPortrait.visible = true
	else:
		$CharacterPortrait.visible = false


func add_dialog(json: Array) -> void:
	_dialog = json
	run_dialog()


func close_dialog() -> void:
	hide()
	#NOTE: Let the Gamestate close the dialog to ensure other processes are completed
	Gamestate.close_dialog()


func run_dialog() -> void:
	_current_dialog = 0
	add_text()
	add_portrait()


func _next() -> void:
	_current_dialog += 1
	if _current_dialog < _dialog.size():
		add_text()
		add_portrait()
	else:
		close_dialog()


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("use"):
		_next()
