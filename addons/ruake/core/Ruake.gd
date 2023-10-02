class_name Ruake
extends Control

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

signal history_changed(complete_history)
signal expression_changed(string)

static func get_setting_or_default(setting_path):
	if(ProjectSettings.has_setting(setting_path)):
		return ProjectSettings.get_setting(setting_path)
	else:
		return SETTINGS_WITH_DEFAULTS[setting_path]

static func toggle_action_name() -> String:
	return get_setting_or_default(SETTING_PATHS.TOGGLE_ACTION)

static func ruake_layer() -> int:
	return get_setting_or_default(SETTING_PATHS.LAYER)

static func pauses_while_opened() -> bool:
	return get_setting_or_default(SETTING_PATHS.PAUSES_WHILE_OPENED)

const RmScene = preload("./rm_scene.gd")
var object
var prompt
var rich_text_label
var expression = ""
var history = []
var history_idx = 0
var scrolling_history = false
var scene_tree
var self_label
var filter_text = ""
var filter_exact_match = false
var proximity_to_runa_filter = NoFilter.new()
var variables = {}


func variables_names():
	return variables.keys()


func variables_values():
	return variables.values()


func _ready():
	rich_text_label = $HBoxContainer/VBoxContainer/RichTextLabel
	prompt = $HBoxContainer/VBoxContainer/HBoxContainer/LineEdit
	scene_tree = $HBoxContainer/VBoxContainer2/Tree
	self_label = $HBoxContainer/VBoxContainer/HBoxContainer/SelfObject
	prompt.text = expression
	object = _root()
	self_label.text = object.to_string()
	prompt.connect("up", self, "go_up_in_history")
	prompt.connect("down", self, "go_down_in_history")
	grab_focus()
	_update_scene_tree()


func grab_focus():
	_update_scene_tree()
	prompt.grab_focus()


func _root():
	return get_node("/root")


func _update_scene_tree():
	scene_tree.clear()
	var filters = []
	if filter_exact_match:
		filters.push_front(NameExactlyMatches.new(filter_text))
	else:
		filters.push_front(NameContains.new(filter_text))
	filters.push_front(proximity_to_runa_filter)
	var filter = And.new(filters)
	RmScene.new(_root()).insert_into_tree(scene_tree, filter, true)


func has_variable(name):
	return variables.has(name)


func set_variable(name, value):
	variables[name] = value


func go_up_in_history():
	if not history.empty():
		if not scrolling_history:
			history_idx = 0
			scrolling_history = true
		else:
			history_idx = (history_idx + 1) % history.size()
		prompt.text = history[history_idx].prompt


func go_down_in_history():
	if not history.empty():
		if not scrolling_history:
			history_idx = 0
			scrolling_history = true
		history_idx = (history_idx - 1) % history.size()
		prompt.text = history[history_idx].prompt


func _on_LineEdit_text_entered(new_text):
	evaluate_expression(new_text)


func _on_Button_pressed():
	evaluate_expression(prompt.text)


func evaluate_expression(a_prompt):
	var evaluation = execute(a_prompt)

	evaluation.print()
	evaluation.write_in(rich_text_label)
	history.push_front(evaluation)
	emit_signal("history_changed", history)
	clear_prompt()


func clear_prompt():
	prompt.text = ""


func execute(a_prompt):
	if not is_instance_valid(object):
		_set_object(_root())
		_update_scene_tree()
		return Evaluation.new(
			object,
			a_prompt,
			"El objeto ya no existe, reseteando a /root",
			Evaluation.Failure
		)

	return RuakeExpression.for(object, a_prompt).execute_in(self)


func _on_LineEdit_text_changed(new_text):
	scrolling_history = false
	emit_signal("expression_changed", object, new_text)


func _on_Tree_item_selected():
	var a_object = scene_tree.get_selected().get_metadata(0)
	if is_instance_valid(a_object):
		_set_object(a_object)
	else:
		_set_object(_root())
		_update_scene_tree()


func _set_object(an_object):
	object = an_object
	self_label.text = object.to_string()


func _on_SearchPrompt_text_changed(new_text):
	filter_text = new_text
	_update_scene_tree()


func _on_ExactSearchMatch_toggled(value):
	filter_exact_match = value
	_update_scene_tree()


class RuakeExpression:
	static func assignment_regex():
		var assignment_regex := RegEx.new()
		var _ignored = assignment_regex.compile(
			"^ *var +(?<variable_name>\\w*) *="
		)
		return assignment_regex

	static func reassignment_regex():
		var assignment_regex := RegEx.new()
		var _ignored = assignment_regex.compile(
			"^ *(?<variable_name>\\w*) *="
		)
		return assignment_regex

	static func for(object, prompt):
		var assignment_regex = assignment_regex()
		var assignment_regex_match = assignment_regex.search(prompt)
		var reassignment_regex = reassignment_regex()
		var reassignment_regex_match = reassignment_regex.search(
			prompt
		)
		if assignment_regex_match:
			return RuakeAssignment.new(
				object,
				assignment_regex_match.get_string("variable_name"),
				assignment_regex.sub(prompt, ""),
				prompt
			)
		elif reassignment_regex_match:
			return RuakeReassignment.new(
				object,
				reassignment_regex_match.get_string("variable_name"),
				reassignment_regex.sub(prompt, ""),
				prompt
			)
		else:
			return RuakeGodotExpression.new(object, prompt)


class RuakeReassignment:
	var object
	var variable_name
	var result_expression_prompt
	var original_prompt

	func _init(
		_object,
		_variable_name,
		_result_expression_prompt,
		_original_prompt
	):
		object = _object
		variable_name = _variable_name
		result_expression_prompt = _result_expression_prompt
		original_prompt = _original_prompt

	func execute_in(ruake) -> Evaluation:
		var evaluation_result
		if ruake.has_variable(variable_name):
			evaluation_result = RuakeGodotExpression.new(object, result_expression_prompt).execute_in(
				ruake
			)
			if (
				Evaluation.Success
				== evaluation_result.result_success_state
			):
				ruake.set_variable(
					variable_name, evaluation_result.result_value
				)
			evaluation_result.prompt = original_prompt
		else:
			evaluation_result = Evaluation.new(
				object,
				original_prompt,
				str("Variable ", variable_name, " does not exist"),
				Evaluation.Failure
			)
		return evaluation_result


class RuakeAssignment:
	var object
	var variable_name
	var result_expression_prompt
	var original_prompt

	func _init(
		_object,
		_variable_name,
		_result_expression_prompt,
		_original_prompt
	):
		object = _object
		variable_name = _variable_name
		result_expression_prompt = _result_expression_prompt
		original_prompt = _original_prompt

	func execute_in(ruake) -> Evaluation:
		var evaluation_result = RuakeGodotExpression.new(object, result_expression_prompt).execute_in(
			ruake
		)
		if (
			Evaluation.Success
			== evaluation_result.result_success_state
		):
			ruake.set_variable(
				variable_name, evaluation_result.result_value
			)
		evaluation_result.prompt = original_prompt
		return evaluation_result


class RuakeGodotExpression:
	var object
	var prompt

	func _init(_object, _prompt):
		object = _object
		prompt = _prompt

	func execute_in(ruake) -> Evaluation:
		var expression = Expression.new()
		var parsing_result = expression.parse(
			SyntaxSugarer.new().sugared_expression(prompt),
			ruake.variables_names()
		)
		var result_value
		var result_success_state

		if parsing_result != OK:
			result_value = expression.get_error_text()
			result_success_state = Evaluation.Failure
		else:
			var execution_result = expression.execute(
				ruake.variables_values(), object, true
			)
			if expression.has_execute_failed():
				result_value = "Execution failed, check the debugger console"
				result_success_state = Evaluation.Failure
			else:
				result_value = execution_result
				result_success_state = Evaluation.Success

		return Evaluation.new(
			object, prompt, result_value, result_success_state
		)


class Evaluation:
	enum { Success, Failure }

	var object
	var prompt
	var result_value
	var result_success_state

	func _init(
		an_object, a_prompt, a_result_value, a_result_success_state
	):
		prompt = a_prompt
		result_value = a_result_value
		object = an_object
		result_success_state = a_result_success_state

	func is_failure():
		return result_success_state == Failure

	func serialized():
		return {
			"prompt": prompt,
			"result_value": str(result_value),
			"result_value_success_state": result_success_state
		}

	func print():
		print(object, ">> ", prompt)
		print("Result value: ", result_value)

	func write_in(text_label):
		text_label.bbcode_text += str("> ", prompt)
		text_label.bbcode_text += "\n"
		match result_success_state:
			Success:
				text_label.bbcode_text += str(result_value)
			Failure:
				text_label.bbcode_text += str(
					"[color=red]", result_value, "[/color]"
				)
		text_label.bbcode_text += "\n"


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


func _on_CloseToRunaFilter_filter_changed(new_filter):
	proximity_to_runa_filter = new_filter
	_update_scene_tree()
