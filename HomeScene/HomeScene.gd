extends Control
func _on_PlayButton_pressed():
	#go to 3d terrain
	#get_tree().change_scene_to_file("res://WorldTerrain.tscn")
	#go to cinematic
	get_tree().change_scene_to_file("res://CinematicScenes/FirstCinematic.tscn") # Replace with your 3D game scene path

func _on_LoadGameButton_pressed():
	get_tree().change_scene_to_file("res://LoadGameScene/LoadGameScene.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()
