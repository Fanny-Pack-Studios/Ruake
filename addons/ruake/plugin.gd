tool
extends EditorPlugin

const IN_EDITOR_REPL = preload("res://addons/ruake/core/REPL/InEditorREPL.tscn")

var in_editor_repl
func _enter_tree():
	for setting_path in Ruake.SETTINGS_WITH_DEFAULTS:
		if(not ProjectSettings.has_setting(setting_path)):
			var default_value = Ruake.SETTINGS_WITH_DEFAULTS[setting_path]
			ProjectSettings.set_setting(setting_path, default_value)
			ProjectSettings.set_initial_value(setting_path, default_value)

	add_autoload_singleton(
		"RuakeLayer",
		"res://addons/ruake/core/RuakeLayer.tscn"
	)
	in_editor_repl = IN_EDITOR_REPL.instance()
	add_control_to_bottom_panel(in_editor_repl, "REPL")


func _exit_tree():
	remove_autoload_singleton("RuakeLayer")
	if(in_editor_repl):
		remove_control_from_bottom_panel(in_editor_repl)
		in_editor_repl.queue_free()
	
