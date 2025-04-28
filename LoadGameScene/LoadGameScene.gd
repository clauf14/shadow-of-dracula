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
		print("⚠️ Nu există date de salvare în Global!")
		return
	
	if not Global.save_data.has(load_slot):
		print("⚠️ Slotul de salvare '", load_slot, "' nu există în fișier!")
		return

	var knight_instance = get_tree().current_scene.get_node("Knight")
	if knight_instance:
		var slot_data = Global.save_data[load_slot]["position"]
		knight_instance.global_transform.origin = Vector3(slot_data.x, slot_data.y, slot_data.z)
		print("✅ Knight a fost repoziționat conform slotului: ", load_slot)
	else:
		print("⚠️ Knight nu există în scenă!")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://HomeScene/HomeScene.tscn")
