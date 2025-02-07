@tool
extends VBoxContainer

const RmScene = preload("res://addons/ruake/core/rm_scene.gd")

var filter_text = ""
var filter_exact_match = false
@onready var scene_tree = %SceneTree
@onready var refresh = %Refresh
@onready var search_prompt = %SearchPrompt
@onready var exact_search_match = %ExactSearchMatch

signal node_chosen(node)

func _ready():
	update_scene_tree()
	refresh.pressed.connect(self.update_scene_tree)
	scene_tree.item_selected.connect(self.on_scene_tree_item_selected)
	search_prompt.text_changed.connect(self._on_SearchPrompt_text_changed)
	exact_search_match.toggled.connect(self._on_ExactSearchMatch_toggled)

func root_node():
	return get_node("/root")

func update_scene_tree():
	scene_tree.clear()
	var filters = []
	if filter_exact_match:
		filters.push_front(NameExactlyMatches.new(filter_text))
	else:
		filters.push_front(NameContains.new(filter_text))
	var filter = And.new(filters)
	RmScene.new(root_node()).insert_into_tree(scene_tree, filter, true)

func on_scene_tree_item_selected():
	var a_object = scene_tree.get_selected().get_metadata(0)
	if is_instance_valid(a_object):
		node_chosen.emit(a_object)
	else:
		node_chosen.emit(root_node())
		update_scene_tree()

func _on_SearchPrompt_text_changed(new_text):
	filter_text = new_text
	update_scene_tree()

func _on_ExactSearchMatch_toggled(value):
	filter_exact_match = value
	update_scene_tree()

class NoFilter:
	func was_met(_node):
		return true

class NameContains:
	var substring

	func _init(a_substring):
		substring = a_substring

	func was_met(node):
		return (
			(substring.to_upper() in node.name.to_upper())
			or substring == ""
		)

class NameExactlyMatches:
	var string

	func _init(a_string):
		string = a_string

	func was_met(node):
		return string.to_upper() == node.name.to_upper()

class And:
	var filters

	func _init(some_filters):
		filters = some_filters

	func was_met(node):
		for filter in filters:
			if not filter.was_met(node):
				return false
		return true
