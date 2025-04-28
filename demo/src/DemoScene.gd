@tool
extends Node

@onready var terrain: Terrain3D = find_child("Terrain3D")

func _ready():
	if not Engine.is_editor_hint() and has_node("UI"):
		$UI.player = $Knight

		if Global.save_data != null:
			if Global.save_data != null and Global.load_slot != "":
				if Global.save_data.has(Global.load_slot):
					var knight_instance = get_node_or_null("Knight")
					if knight_instance:
						var slot_data = Global.save_data[Global.load_slot]["position"]
						knight_instance.global_transform.origin = Vector3(
							slot_data.x,
							slot_data.y,
							slot_data.z
					)
					print("✅ The knight's position has been applied from slot: ", Global.load_slot)
				else:
					print("⚠️ The knight was not found!")
			else:
				print("⚠️ Slot ", Global.load_slot, " not found in save data!")
		else:
			print("⚠️ No save data or no load_slot found in Global!")


	if Engine.is_editor_hint() and has_node("Environment") and \
		Engine.get_singleton(&"EditorInterface").is_plugin_enabled("sky_3d"):
			$Environment.queue_free()
			var sky3d = load("res://addons/sky_3d/src/Sky3D.gd").new()
			sky3d.name = "Sky3D"
			add_child(sky3d, true)
			move_child(sky3d, 1)
			sky3d.owner = self
			sky3d.current_time = 10
			sky3d.enable_editor_time = false
