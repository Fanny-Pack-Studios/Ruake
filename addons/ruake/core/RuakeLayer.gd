extends CanvasLayer

var ruake_menu
const RuakeScene = preload("./Ruake.tscn")
var action_name

func _ready():
	var configured_action_name := Ruake.toggle_action_name()
	if InputMap.has_action(configured_action_name):
		action_name = configured_action_name
	_create_ruake()
	# TODO: save history
	#ruake_menu.history = []


func _physics_process(_delta):
	if action_name and Input.is_action_just_pressed(action_name):
		toggle_ruake()

func _create_ruake():
	ruake_menu = RuakeScene.instantiate()


func toggle_ruake():
	if not ruake_menu:
		_create_ruake()
	if ruake_menu.get_parent() == self:
		remove_child(ruake_menu)
		get_tree().paused = false
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		add_child(ruake_menu)
		get_tree().paused = true
		ruake_menu.be_focused()
