extends Node

var awake: bool = true
var run_enabled: bool = false
var _dialog_scene:PackedScene = preload("res://UI/DialogManager.tscn")
var opened_dialog: Node


func open_dialog(dialog_path: String) -> void:
	# TODO: Open dialog file and read it.

	opened_dialog = _dialog_scene.instance()
	var dialog_layer: CanvasLayer = get_tree().get_nodes_in_group("DialogLayer")[0]
	opened_dialog.add_text("Welcome, Philippos. Make yourself at home.")
	dialog_layer.add_child(opened_dialog)


func close_dialog() -> void:
	opened_dialog.hide()
	opened_dialog.queue_free()
