tool
extends Control

onready var repl = $"%REPL"
onready var editor_eye_dropper = $"%EditorEyeDropper"
const HISTORY_SAVER = preload("res://addons/ruake/core/history_saver.gd")
const IN_EDITOR_HISTORY_PATH = "user://in_editor_ruake_history.json"

func _ready():
	EditorPlugin.new().get_editor_interface().get_selection().connect(
		"selection_changed", self, "on_selection_changed"
	)
	editor_eye_dropper.connect("node_selected", self, "on_control_selected")
	repl.history = HISTORY_SAVER.read(IN_EDITOR_HISTORY_PATH)
	repl.connect("history_changed", self, "on_history_changed")

func on_history_changed(new_history):
	HISTORY_SAVER.write(new_history, IN_EDITOR_HISTORY_PATH)

func on_control_selected(control):
	repl._set_object(control)

func on_selection_changed():
	var selected_nodes = EditorPlugin.new().get_editor_interface().get_selection().get_selected_nodes()
	if(selected_nodes.size() == 1):
		var selected_node = selected_nodes.front()
		repl._set_object(selected_node)
