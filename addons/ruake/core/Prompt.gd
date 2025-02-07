@tool
extends LineEdit

signal up
signal down


func _gui_input(event):
	if event is InputEventKey and not event.is_echo():
		if event.is_action_pressed("ui_up"):
			accept_event()
			emit_signal("up")
		if event.is_action_pressed("ui_down"):
			accept_event()
			emit_signal("down")
