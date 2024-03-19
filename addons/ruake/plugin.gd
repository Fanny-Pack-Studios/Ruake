@tool
extends EditorPlugin

const IN_EDITOR_REPL = preload("res://addons/ruake/core/REPL/InEditorREPL.tscn")

var ruake_bottom_menu

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
	ruake_bottom_menu = IN_EDITOR_REPL.instantiate()
	#ruake_bottom_menu = Button.new()
	#ruake_bottom_menu.pressed.connect(func(): print("a"))
	add_control_to_bottom_panel(ruake_bottom_menu, "REPL")


func _exit_tree():
	remove_autoload_singleton("RuakeLayer")
	remove_control_from_bottom_panel(ruake_bottom_menu)
	ruake_bottom_menu.queue_free()
