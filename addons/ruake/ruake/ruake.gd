@tool
class_name Ruake
extends Control

const HISTORY_SAVE_FILE_PATH = "user://ruake_in_game_history.txt"

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
	return ProjectSettings.get_setting(
		SETTING_PATHS.TOGGLE_ACTION,
		SETTINGS_WITH_DEFAULTS[SETTING_PATHS.TOGGLE_ACTION]
	)

static func layer() -> int:
	return ProjectSettings.get_setting(
		SETTING_PATHS.LAYER,
		SETTINGS_WITH_DEFAULTS[SETTING_PATHS.LAYER]
	)

static func pauses_while_opened() -> bool:
	return ProjectSettings.get_setting(
		SETTING_PATHS.PAUSES_WHILE_OPENED,
		SETTINGS_WITH_DEFAULTS[SETTING_PATHS.PAUSES_WHILE_OPENED]
	)

@onready var repl = %REPL
@onready var ruake_tree = %RuakeTree

func _ready():
	repl.history_filepath = HISTORY_SAVE_FILE_PATH
	repl.load_history()
	ruake_tree.node_chosen.connect(Callable(self, "on_node_chosen"))
	_set_object(ruake_tree.root_node())
	be_focused()

func be_focused():
	ruake_tree.update_scene_tree()
	repl.be_focused()

func on_node_chosen(node):
	_set_object(node)
	repl.be_focused()
	repl.select_all()

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
