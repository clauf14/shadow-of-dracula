extends Control

func _ready():
	visible = false

func resume():
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func pause():
	get_tree().paused = true
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func testEsc():
	if Input.is_action_just_pressed("pause_game") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause_game") and get_tree().paused:
		resume()

func _process(_delta):
	testEsc()

func _on_resume_pressed():
	resume()


func _on_save_game_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
