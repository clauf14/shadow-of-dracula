extends Control

var save_path = "user://savegame.save"
var load_slot = ""

func _on_load_game_1_pressed() -> void:
	load_slot = "save_game_1"
	load_game_scene()

func _on_load_game_2_pressed() -> void:
	load_slot = "save_game_2"
	load_game_scene()

func _on_load_game_3_pressed() -> void:
	load_slot = "save_game_3"
	load_game_scene()

func load_game_scene() -> void:
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var json_data = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_data)
		if parse_result == OK:
			Global.save_data = json.get_data()
			Global.load_slot = load_slot
			get_tree().change_scene_to_file("res://Demo/Demo.tscn")
		else:
			print("⚠️ Eroare la parsat fișierul de salvare!")
	else:
		print("⚠️ Fișierul nu există!")

func _on_scene_loaded() -> void:
	if Global.save_data == null:
		return
	
	if not Global.save_data.has(load_slot):
		return

	var knight_instance = get_tree().current_scene.get_node("Knight")
	if knight_instance:
		var slot_data = Global.save_data[load_slot]

		if slot_data.has("position"):
			var pos = slot_data["position"]
			knight_instance.global_transform.origin = Vector3(pos.x, pos.y, pos.z)

		if slot_data.has("health"):
			knight_instance.curHp = slot_data["health"]
			if knight_instance.has_node("CanvasLayer/UIPlayer"):
				var ui = knight_instance.get_node("CanvasLayer/UIPlayer")
				if ui:
					ui.update_health_bar(knight_instance.curHp, knight_instance.maxHp)
	else:
		print("Knight does not exist in the scene!")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://HomeScene/HomeScene.tscn")
