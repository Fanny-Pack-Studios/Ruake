tool
extends Object
const REPL = preload("res://addons/ruake/core/REPL/REPL.gd")
const HISTORY_PATH := "user://ruake_history.txt"

static func write(history: Array) -> void:
	var file = File.new()
	file.open(HISTORY_PATH, File.WRITE)
	var serialized_history = []
	for evaluation in history:
		serialized_history.push_back(evaluation.serialized())
	var json_history = JSON.print(serialized_history)
	file.store_string(json_history)
	file.close()

static func clear():
	write([])

static func read() -> Array:
	var file = File.new()
	var error = file.open(HISTORY_PATH, File.READ)
	if error != OK:
		return []
	var parse_result = JSON.parse(file.get_as_text())
	file.close()
	if(parse_result.error != OK):
		return []

	var history = []
	for result in parse_result.result:
		history.push_back(REPL.Evaluation.from_dict(result))
	return history
