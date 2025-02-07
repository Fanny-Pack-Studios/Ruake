@tool
extends CanvasLayer

var is_active = false
var last_focused_control = null
@onready var mouse_pointer = %MousePointer
@onready var search_again_timer = %SearchAgainTimer
@onready var eye_dropper_button: CheckButton = %EyeDropperButton

signal node_selected(node)

func _ready():
	eye_dropper_button.toggled.connect(func(value):
		is_active = value
	)
	search_again_timer.timeout.connect(func():
		var newly_focused_control = focused_control(get_viewport().get_mouse_position())
		if(is_instance_valid(last_focused_control)):
			last_focused_control.modulate = Color.WHITE
		if(not is_active): return
		if newly_focused_control is Control:
			newly_focused_control.modulate = Color.GREEN
			last_focused_control = newly_focused_control
	)

func _input(event):
	if event is InputEventMouseButton and is_active:
		var click_event = event as InputEventMouseButton
		if(click_event.pressed and click_event.button_index == MOUSE_BUTTON_LEFT):
			get_viewport().set_input_as_handled()
			if(last_focused_control):
				node_selected.emit(last_focused_control)
			eye_dropper_button.button_pressed = false

func _physics_process(delta):
	mouse_pointer.visible = is_active
	var mouse_position = get_viewport().get_mouse_position()
	mouse_pointer.global_position = mouse_position


func focused_control(mouse_position: Vector2):
	var root = get_tree().root
	return _focused_control(mouse_position, root, root)

func _focused_control(mouse_position: Vector2, current_result: Node, node_to_search_in):
	var new_result = current_result
	if(node_to_search_in is Control):
		var control_node: Control = node_to_search_in
		if(control_node.is_visible_in_tree()):
			if(control_node.get_global_rect().has_point(mouse_position)):
				new_result = control_node
		else:
			return null

	var node_children = node_to_search_in.get_children(true)
	node_children.reverse()
	if not node_children.is_empty():
		for child in node_children:
			var result_node = _focused_control(mouse_position, new_result, child)
			if(result_node):
				new_result = result_node

	return new_result
