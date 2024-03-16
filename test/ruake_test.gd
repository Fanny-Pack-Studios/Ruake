extends GutTest

const RUAKE = preload("res://addons/ruake/core/Ruake.tscn")

func before_each():
	gut.p("ran setup", 2)

func after_each():
	gut.p("ran teardown", 2)

func before_all():
	gut.p("ran run setup", 2)

func after_all():
	gut.p("ran run teardown", 2)

func create_ruake() -> Ruake:
	return add_child_autoqfree(RUAKE.instantiate())

func set_ruake_prompt(ruake: Ruake, text: String) -> void:
	ruake.prompt.text = text

func test_assert_ruake_prompt_starts_empty():
	var ruake = create_ruake()
	assert_eq(ruake.current_prompt(), "")

func test_assert_ruake_prompt_empties_after_evaluating():
	var ruake = create_ruake()
	ruake.write_prompt("2 + 2")
	assert_eq(ruake.current_prompt(), "2 + 2")
	
	ruake.evaluate_current_prompt()
	
	assert_eq(ruake.current_prompt(), "")

func test_assert_ruake_prompt_remembers_previous_prompts():
	var ruake = create_ruake()
	ruake.write_prompt("2 + 2")
	ruake.evaluate_current_prompt()
	
	ruake.go_up_in_history()
	
	assert_eq(ruake.current_prompt(), "2 + 2")

func test_assert_ruake_prompt_history_remembers_several_prompts():
	var ruake = create_ruake()
	ruake.write_prompt("2 + 2")
	ruake.evaluate_current_prompt()
	ruake.write_prompt("'This is the pencil of Esther Piscore.'")
	ruake.evaluate_current_prompt()
	
	ruake.go_up_in_history()
	assert_eq(ruake.current_prompt(), "'This is the pencil of Esther Piscore.'")
	ruake.go_up_in_history()
	assert_eq(ruake.current_prompt(), "2 + 2")


