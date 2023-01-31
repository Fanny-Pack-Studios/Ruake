extends CanvasLayer

var ruake_menu
const Ruake = preload("./Ruake.tscn")


func _ready():
	_create_ruake()
	# TODO: recuperar historial
	ruake_menu.history = []


func _physics_process(_delta):
	if Input.is_action_just_pressed("debug_toggle"):
		toggle_ruake()


func _create_ruake():
	ruake_menu = Ruake.instantiate()
	ruake_menu.connect("history_changed",Callable(self,"ruake_history_changed"))


func toggle_ruake():
	if not ruake_menu:
		_create_ruake()
	if ruake_menu.get_parent() == self:
		remove_child(ruake_menu)
		get_tree().paused = false
		# Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		add_child(ruake_menu)
		ruake_menu.grab_focus()
		get_tree().paused = true
		# Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func ruake_history_changed(history):
	# TODO: guardar historial
	pass


func serialized_history(history):
	var serliazed_history = []
	for evaluation in history:
		var serialized_evaluation = (
			evaluation
			if (evaluation is Dictionary)
			else evaluation.serialized()
		)
		serliazed_history.push_front(serialized_evaluation)
	return serliazed_history
