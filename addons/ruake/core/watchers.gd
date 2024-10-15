extends Control

const InWorldLabelFont = preload("res://addons/ruake/core/ruake_in_world_label_font.tres")

onready var ruake = get_parent()
var watchers = []

func clear_in_world_watchers():
	for watcher in watchers:
		watcher.stop_showing_in_spatial()

func clear():
	for watcher in watchers:
		watcher.clear()
	$"%WatchList".clear()
	watchers.clear()

func _process(_delta):
	visible = $"%WatchList".get_item_count() > 0

func add_watcher_for(evaluation_context, expression):
	var watcher = Watcher.new(evaluation_context, expression, ruake)
	watcher.connect("no_longer_valid", self, "remove_watcher")
	watchers.push_front(watcher)
	watcher.show_in_list($"%WatchList")
	
func add_in_world_watcher_for(evaluation_context, expression):
	var watcher = Watcher.new(evaluation_context, expression, ruake)
	watchers.push_front(watcher)
	watcher.show_in_spatial(evaluation_context)

func remove_watcher(watcher):
	watcher.clear()
	watchers.erase(watcher)

func _physics_process(_delta):
	for watcher in watchers:
		watcher.update_text()

class Watcher:
	extends Reference
	var evaluation_context
	var expression
	var labels = []
	var ruake
	
	signal no_longer_valid

	func _init(an_evaluation_context, an_expression, _ruake):
		evaluation_context = an_evaluation_context
		expression = an_expression
		ruake = _ruake

	func add_label(watcher_label):
		var label = watcher_label
		labels.push_front(label)
		label.setup(self)
		return label
		
	func stop_showing_in_spatial():
		for label in labels:
			if label.is_in_world_label():
				label.clear()
				labels.erase(label)

	func show_in_list(watch_list):
		return add_label(WatchListLabel.new(watch_list))

	func show_in_spatial(an_spatial):
		return add_label(InWorldLabel.new(evaluation_context))

	func update_text():
		if not is_instance_valid(evaluation_context):
			emit_signal("no_longer_valid", self)
			return
		if(evaluation_context.is_physics_processing() or ruake.get_node("/root") == evaluation_context):
			for label in labels:
				label.update_text(evaluation_context, expression, evaluate_and_print())

	func clear():
		for label in labels:
			label.clear()
		labels.clear()

	func evaluate_and_print():
		var evaluation = expression.execute_in(ruake)
		return str(evaluation.result_value)

class WatchListLabel:
	extends Reference
	var idx
	var list
	
	func _init(watch_list):
		idx = watch_list.get_item_count()
		list = watch_list
	
	func setup(watcher):
		list.add_item(watcher.evaluate_and_print())
	
	func update_text(evaluation_context, expression, value):
		list.set_item_text(idx, str(evaluation_context, " -- ", expression.prompt, " --- ", value))
	
	func clear():
		pass
		
	func is_in_world_label():
		return false

class InWorldLabel:
	extends Reference
	var spatial
	var label_3d
	
	func _init(an_spatial):
		spatial = an_spatial
	
	func setup(watcher):
		label_3d = Label3D.new()
		label_3d.billboard = SpatialMaterial.BILLBOARD_ENABLED
		label_3d.offset = Vector2.DOWN * 200.0
		label_3d.no_depth_test = true
		spatial.add_child(label_3d)
		label_3d.text = watcher.evaluate_and_print()
		label_3d.font = InWorldLabelFont
		
	func update_text(evaluation_context, expression, value):
		if(is_instance_valid(label_3d)):
			label_3d.text = str(value)
	
	func clear():
		if is_instance_valid(label_3d):
			label_3d.queue_free()

	func is_in_world_label():
		return true
