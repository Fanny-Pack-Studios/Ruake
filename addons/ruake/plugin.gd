@tool
extends EditorPlugin

func _enter_tree():
	for setting_path in Ruake.SETTINGS_WITH_DEFAULTS:
		if(not ProjectSettings.has_setting(setting_path)):
			var default_value = Ruake.SETTINGS_WITH_DEFAULTS[setting_path]
			ProjectSettings.set_setting(setting_path, default_value)
			ProjectSettings.set_initial_value(setting_path, default_value)
			ProjectSettings.set_as_basic(setting_path, true)

	add_autoload_singleton(
		"RuakeLayer",
		"res://addons/ruake/core/RuakeLayer.tscn"
	)


func _exit_tree():
	remove_autoload_singleton("RuakeLayer")
