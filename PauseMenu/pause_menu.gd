extends Control

var save_path = "user://savegame.save"

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

func _on_save_game_pressed(button_index: int) -> void:
	var player = get_node("/root/Demo/Knight")

	if player:
		var save_data = {}

		if FileAccess.file_exists(save_path):
			var file = FileAccess.open(save_path, FileAccess.READ)
			var json_data = file.get_as_text()
			var json = JSON.new()
			var parse_result = json.parse(json_data)
			if parse_result == OK:
				save_data = json.get_data()

		save_data["save_game_" + str(button_index)] = {
			"position": {
				"x": player.global_transform.origin.x,
				"y": player.global_transform.origin.y,
				"z": player.global_transform.origin.z
			},
			"health": player.curHp
		}
		
		var json_string = JSON.stringify(save_data, "", 4)
		var file = FileAccess.open(save_path, FileAccess.WRITE)
		file.store_string(json_string)
		print("Save game successfully!")
	else:
		print("Knight was not found in the tree!")

func _on_save_1_pressed() -> void:
	_on_save_game_pressed(1) 

func _on_save_2_pressed() -> void:
	_on_save_game_pressed(2) 

func _on_save_3_pressed() -> void:
	_on_save_game_pressed(3) 

func _on_back_to_menu_pressed() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://HomeScene/HomeScene.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
