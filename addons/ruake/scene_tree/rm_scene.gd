extends Object

var scene
var editor_plugin

func _init(_scene,_editor_plugin = null):
	scene = _scene
	editor_plugin = _editor_plugin

func insert_into_tree(tree: Tree, filter_condition, hide_non_eligible = false) -> void:
	add_node_to_tree_item(scene, scene, tree.create_item(), tree, filter_condition, hide_non_eligible)

func add_node_to_tree_item(root_node, node, tree_item, tree, condition, hide_non_eligible) -> void:
	tree_item.set_text(0, node.name)
	tree_item.set_icon(0, icon(node))
	var node_eligibility = _node_eligibility(node, condition)
	
	if node_eligibility.selectable:
		tree_item.set_metadata(0, node)
		tree_item.set_custom_color(0, Color.CHARTREUSE)
		tree_item.set_selectable(0, true)
		tree_item.set_collapsed(not node_eligibility.has_selectable_child)
	elif node_eligibility.has_selectable_child:
		tree_item.set_custom_color(0, Color.AQUAMARINE)
		tree_item.set_selectable(0, false)
		tree_item.set_collapsed(false)
	else:
		tree_item.set_custom_color(0, Color.GRAY)
		tree_item.set_selectable(0, false)
		tree_item.set_collapsed(true)
		if(hide_non_eligible):
			tree_item.free()


	if node_eligibility.has_selectable_child:
		for child in node.get_children():
			add_node_to_tree_item(root_node, child, tree.create_item(tree_item), tree, condition, hide_non_eligible)

func _node_eligibility(node, condition):
	var selectable = _node_is_selectable(node, condition)
	var has_selectable_child = _node_has_selectable_child(node, condition)
	
	return { "selectable": selectable, "has_selectable_child": has_selectable_child }

func _node_is_selectable(node, condition):
	return condition.was_met(node)

func _node_has_selectable_child(node, condition):
	for child in node.get_children():
		if condition.was_met(child) or _node_has_selectable_child(child, condition):
			return true
	return false

func icon(node) -> Texture2D:
	var custom_icon = _custom_icon_or_null(node)
	if(custom_icon):
		return custom_icon
	else:
		return _builtin_icon(node)

func _builtin_icon(node) -> Texture2D:
	if not editor_plugin:
		return null

	var gui = editor_plugin.get_editor_interface().get_base_control()
	return gui.get_icon(node.get_class(), "EditorIcons")

func _custom_icon_or_null(node) -> Texture2D:
	# TODO: figure out how to do this in godot 4
	return null
