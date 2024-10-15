tool
class_name Ruake
extends Control

const HISTORY_SAVER = preload("res://addons/ruake/core/history_saver.gd")

const SETTING_PATHS = {
	TOGGLE_ACTION = "addons/ruake/toggle_ruake_action",
	LAYER = "addons/ruake/layer",
	PAUSES_WHILE_OPENED = "addons/ruake/pauses_tree_while_opened"
}

const SETTINGS_WITH_DEFAULTS = {
	SETTING_PATHS.TOGGLE_ACTION: "toggle_ruake",
	SETTING_PATHS.LAYER: 0,
	SETTING_PATHS.PAUSES_WHILE_OPENED: true
}

static func toggle_action_name() -> String:
	var value = ProjectSettings.get_setting(SETTING_PATHS.TOGGLE_ACTION)
	if(not value):
		value = SETTINGS_WITH_DEFAULTS[SETTING_PATHS.TOGGLE_ACTION]
	return value

onready var repl = get_node("%REPL")
onready var ruake_tree = get_node("%RuakeTree")

func _ready():
	ruake_tree.connect("node_chosen", self, "on_node_chosen")
	_set_object(ruake_tree.root_node())
	be_focused()
	repl.history = HISTORY_SAVER.read()
	repl.connect("history_changed", self, "on_history_changed")

func on_history_changed(new_history):
	HISTORY_SAVER.write(new_history)

func be_focused():
	ruake_tree.update_scene_tree()
	repl.be_focused()

func on_node_chosen(node):
	_set_object(node)

func write_prompt(new_prompt: String):
	repl.write_prompt(new_prompt)

func current_prompt():
	return repl.current_prompt()

func evaluate_current_prompt() -> void:
	repl.evaluate_current_prompt()

func go_up_in_history() -> void:
	repl.go_up_in_history()

func go_down_in_history() -> void:
	repl.go_down_in_history()

func _set_object(an_object):
	repl._set_object(an_object)
