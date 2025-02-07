@tool
extends Control

const HISTORY_SAVE_FILE_PATH = "user://repl_history.txt"

@onready var repl: REPL = %REPL
@onready var editor_eye_dropper = %EditorEyeDropper

func _ready():
	repl.history_filepath = HISTORY_SAVE_FILE_PATH
	repl.load_history()
	EditorInterface.get_selection().selection_changed.connect(self.on_selection_changed)
	editor_eye_dropper.node_selected.connect(func(node):
		repl._set_object(node)
	)

func on_selection_changed():
	var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
	if(selected_nodes.size() == 1):
		var selected_node = selected_nodes.front()
		repl._set_object(selected_node)
