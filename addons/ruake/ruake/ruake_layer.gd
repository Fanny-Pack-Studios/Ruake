extends CanvasLayer

var ruake: Ruake
const RuakeScene = preload("./Ruake.tscn")
var action_name

signal ruake_opened
signal ruake_closed

func _ready():
	var configured_action_name := Ruake.toggle_action_name()
	layer = Ruake.layer()
	if InputMap.has_action(configured_action_name):
		action_name = configured_action_name
	_create_ruake()


func _physics_process(_delta):
	if action_name and Input.is_action_just_pressed(action_name):
		toggle_ruake()


func _create_ruake():
	ruake = RuakeScene.instantiate()


func toggle_ruake():
	if not ruake:
		_create_ruake()
	var is_opened = ruake.is_inside_tree()
	if is_opened:
		remove_child(ruake)
		if Ruake.pauses_while_opened():
			get_tree().paused = false
		ruake_closed.emit()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		add_child(ruake)
		if Ruake.pauses_while_opened():
			get_tree().paused = true
		ruake.be_focused()
		ruake_opened.emit()
