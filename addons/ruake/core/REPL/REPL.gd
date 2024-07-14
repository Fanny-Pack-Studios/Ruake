@tool
extends Control

signal history_changed(complete_history)

var object
var expression = ""
var history = []
var history_idx = 0
var scrolling_history = false
var variables = {}
@onready var rich_text_label = %RichTextLabel
@onready var self_label = %SelfLabel
@onready var prompt = %Prompt


func variables_names():
	return variables.keys()

func variables_values():
	return variables.values()

func initialize_godot_singletons():
	var singletons = {
		"ClassDB": ClassDB,
		"EditorInterface": EditorInterface
	}
	for singleton_name in singletons:
		variables[singleton_name] = singletons[singleton_name]

func initialize_constructors():
	for klass_name in ClassDB.get_class_list():
		if(not variables.has(klass_name)):
			variables[klass_name] = Constructor.new(klass_name)

class Constructor:
	var klass_name: StringName
	
	func _init(_klass_name):
		klass_name = _klass_name
	
	func _to_string():
		return "%s's constructor" % klass_name
	
	func new():
		return ClassDB.instantiate(klass_name)

func _ready():
	initialize_godot_singletons()
	initialize_constructors()
	write_prompt(expression)
	_set_object(_root())
	prompt.connect("up",Callable(self,"go_up_in_history"))
	prompt.connect("down",Callable(self,"go_down_in_history"))
	prompt.connect("text_submitted", Callable(self, "on_prompt_submitted"))
	be_focused()

func on_prompt_submitted(_new_text):
	evaluate_current_prompt()

func be_focused():
	prompt.grab_focus()

func _root():
	return get_node("/root")

func has_variable(name):
	return variables.has(name)

func set_variable(name, value):
	variables[name] = value

func go_up_in_history():
	if not history.is_empty():
		if not scrolling_history:
			history_idx = 0
			scrolling_history = true
		else:
			history_idx = (history_idx + 1) % history.size()
		write_prompt(history[history_idx].prompt)

func go_down_in_history():
	if not history.is_empty():
		if not scrolling_history:
			history_idx = 0
			scrolling_history = true
		history_idx = (history_idx - 1) % history.size()
		write_prompt(history[history_idx].prompt)

func _on_LineEdit_text_entered(new_text):
	write_prompt(new_text)
	evaluate_current_prompt()


func _on_Button_pressed():
	evaluate_current_prompt()


func evaluate_current_prompt():
	evaluate_expression(current_prompt())


func evaluate_expression(a_prompt):
	var evaluation = execute(a_prompt)

	evaluation.print()
	evaluation.write_in(rich_text_label)
	history.push_front(evaluation)
	history_idx = history.size() - 1
	emit_signal("history_changed", history)
	clear_prompt()

func current_prompt() -> String:
	return prompt.text

func clear_prompt():
	write_prompt("")

func write_prompt(new_prompt: String):
	prompt.text = new_prompt

func execute(a_prompt):
	if not is_instance_valid(object):
		_set_object(_root())
		return Evaluation.new(
			object,
			a_prompt,
			"El objeto ya no existe, reseteando a /root",
			Evaluation.Failure
		)

	return RuakeExpression.for_prompt(object, a_prompt).execute_in(self)


func _on_LineEdit_text_changed(new_text):
	scrolling_history = false

func _set_object(node: Node):
	object = node
	self_label.text = node.name


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

	static func for_prompt(object, prompt):
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
		elif variable_name in object:
			evaluation_result = RuakeGodotExpression.new(object, result_expression_prompt).execute_in(
				ruake
			)
			if (
				Evaluation.Success
				== evaluation_result.result_success_state
			):
				object.set(
					variable_name, evaluation_result.result_value
				)
		else:
			evaluation_result = Evaluation.new(
				object,
				original_prompt,
				str("Variable ", variable_name, " does not exist"),
				Evaluation.Failure
			)
		evaluation_result.prompt = original_prompt
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

	func _init(_object,_prompt):
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
				result_value = expression.get_error_text()
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
		text_label.text += str("> ", prompt)
		text_label.text += "\n"
		match result_success_state:
			Success:
				text_label.text += str(result_value)
			Failure:
				text_label.text += str(
					"[color=red]", result_value, "[/color]"
				)
		text_label.text += "\n"
