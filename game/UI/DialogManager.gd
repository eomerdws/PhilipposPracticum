extends Control

var _dialog: Array
var _end_events: Array
var _current_dialog: int = 0
var _completed: bool = false

"""
_dialog is expected to be an array of JSON objects that appear as:
{
	"texture": String
	"text": String
	"animation": String
	"trigger": String    -> Name of a signal to be called, which should be stored in Events
}
"""


func _ready() -> void:
	print(has_end_events())


func add_text() -> void:
	$DilaogWindow/DialogBackground/Dialog.text = _dialog[_current_dialog].text


func add_portrait() -> void:
	$CharacterPortrait.visible = false
	if _dialog[_current_dialog].texture:
		$CharacterPortrait.set_texture(load("res://assets/actors/portraits/" + _dialog[_current_dialog].texture))
		$CharacterPortrait.visible = true
	else:
		$CharacterPortrait.visible = false


func check_play_animation() -> void:
	if _dialog[_current_dialog].animation:
		Events.emit_signal("dialog_calls_animation_play", _dialog[_current_dialog].character, _dialog[_current_dialog].animation)



func add_dialog(json: Array) -> void:
	_dialog = json
	if _dialog.size() > 1:
		$DilaogWindow/Next.connect("pressed", self, "_next")
		$DilaogWindow/Next.visible = true
	run_dialog()


func add_end_events(json: Array) -> void:
	_end_events = json


func has_end_events() -> bool:
	return _end_events.size() > 0


func close_dialog() -> void:
	_completed = true
	Events.emit_signal("dialog_completed")
	hide()
	#NOTE: Let the Gamestate close the dialog to ensure other processes are completed
	Gamestate.close_dialog()


func run_dialog() -> void:
	_current_dialog = 0
	add_text()
	add_portrait()
	check_play_animation()


func _run_end_events() -> void:
	if has_end_events():
		for e in _end_events:
			match e.type:
				"signal":
					Events.emit_signal(e.event.signal)
				"animation":
					Events.emit_signal("dialog_calls_animation_play", e.event.character, e.event.animation)

	close_dialog()

func _next() -> void:
	_current_dialog += 1
	if _current_dialog < _dialog.size():
		add_text()
		add_portrait()
		check_play_animation()
	else:
		_run_end_events()  # NOTE: if the dialog has events run them such as ending animations or transitions



func _unhandled_input(event: InputEvent) -> void:
	if !_completed and Input.is_action_just_pressed("use"):
		_next()
