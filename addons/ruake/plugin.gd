@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("RuakeLayer", "res://addons/ruake/core/RuakeLayer.tscn")


func _exit_tree():
	remove_autoload_singleton("RuakeLayer")
