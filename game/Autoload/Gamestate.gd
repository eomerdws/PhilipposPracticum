extends Node

var awake: bool = true # TODO: Load this user data
var starting: bool = true # TODO: Load this from user data
var run_enabled: bool = false
var _dialog_scene:PackedScene = preload("res://UI/DialogManager.tscn")
var opened_dialog: Node
const DIALOG_ROOT: String = "res://DialogData/"


func _ready() -> void:
	Events.connect("dialog_calls_animation_play", self, "dialog_play_animation")


# Gamestate dialog controls
func open_dialog(dialog_fname: String) -> void:
	var dialog_file = File.new()
	if dialog_file.file_exists(DIALOG_ROOT + dialog_fname):
		dialog_file.open(DIALOG_ROOT + dialog_fname, File.READ)
		var d_json: Dictionary = parse_json(dialog_file.get_as_text())
		dialog_file.close()
		# Open the dialog with selected text
		opened_dialog = _dialog_scene.instance()
		opened_dialog.add_dialog(d_json.dialog)
		var dialog_layer: CanvasLayer = get_tree().get_nodes_in_group("DialogLayer")[0]
		dialog_layer.add_child(opened_dialog)
	else:
		print("Error: Failed to open %s" %dialog_fname)


func close_dialog() -> void:
	if opened_dialog != null and is_instance_valid(opened_dialog):
		opened_dialog.queue_free()


func dialog_play_animation(character_name: String, animation: String) -> void:
	var group: Array = get_tree().get_nodes_in_group(character_name)
	if group.size() > 0:
		print("Calling " + character_name + " to " + animation)
		var character = group[0]
		character.play_animation(animation)
	else:
		print("ERROR: No character name group matching %s." %character_name)


func is_dialog_open() -> bool:
	return is_instance_valid(opened_dialog) and !opened_dialog.is_queued_for_deletion()
