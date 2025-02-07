@tool
extends Control

@onready var repl = %REPL
@onready var editor_eye_dropper = %EditorEyeDropper

func _ready():
	EditorInterface.get_selection().selection_changed.connect(self.on_selection_changed)
	editor_eye_dropper.node_selected.connect(func(node):
		repl._set_object(node)
	)

func on_selection_changed():
	var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
	if(selected_nodes.size() == 1):
		var selected_node = selected_nodes.front()
		repl._set_object(selected_node)
