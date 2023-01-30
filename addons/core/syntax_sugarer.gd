class_name SyntaxSugarer
extends Object

func sugared_expression(prompt):
	var regex = RegEx.new()
	var get_node_finishing_characters = [" ", ".", ","]
	var character_class_for_get_node_finishing_character = str("\\[", "\\|".join(PackedStringArray(get_node_finishing_characters)), "\\]")
	regex.compile(str("\\$([^", character_class_for_get_node_finishing_character, "]*)"))
	var result = regex.sub(prompt, "get_node('$1')", true)
	return result
