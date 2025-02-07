@tool
extends EditorPlugin

const IN_EDITOR_REPL = preload("res://addons/ruake/in_editor_repl/in_editor_repl.tscn")

var in_editor_repl

func _enter_tree():
	for setting_path in Ruake.SETTINGS_WITH_DEFAULTS.keys():
		var default_value = Ruake.SETTINGS_WITH_DEFAULTS[setting_path]
		if(not ProjectSettings.has_setting(setting_path)):
			ProjectSettings.set_setting(setting_path, default_value)
		ProjectSettings.set_initial_value(setting_path, default_value)
		ProjectSettings.set_as_basic(setting_path, true)
		_register_toggle_ruake_input_action()

	add_autoload_singleton("RuakeLayer", "res://addons/ruake/ruake/ruake_layer.tscn")
	in_editor_repl = IN_EDITOR_REPL.instantiate()
	add_control_to_bottom_panel(in_editor_repl, "REPL")


func _exit_tree():
	remove_autoload_singleton("RuakeLayer")
	if in_editor_repl:
		remove_control_from_bottom_panel(in_editor_repl)
		in_editor_repl.queue_free()


func _register_toggle_ruake_input_action():
	var input_action: String = Ruake.toggle_action_name()
	if(not ProjectSettings.has_setting("input/%s" % input_action)):
		var default_input_event := InputEventKey.new()
		default_input_event.ctrl_pressed = true
		default_input_event.keycode = KEY_1
		ProjectSettings.set_setting(
			"input/%s" % input_action,
			{
				"deadzone": 0.5,
				"events": [default_input_event]
			}
		)
		ProjectSettings.set_as_basic("input/%s" % input_action, true)
		ProjectSettings.save()

		var confirmation_dialog := ConfirmationDialog.new()
		confirmation_dialog.dialog_text =\
			"A new action has been created to open Ruake while the game is running:\n\n\t%s -- CTRL + 1\n\n\
			In order to see these changes in the Input Map, the editor needs to be restarted." % input_action
		confirmation_dialog.ok_button_text = "Restart"
		confirmation_dialog.confirmed.connect(func():
			EditorInterface.restart_editor(true)
		)
		EditorInterface.popup_dialog_centered(confirmation_dialog)
