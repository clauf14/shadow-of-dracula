extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_PlayButton_pressed():
	get_tree().change_scene_to_file("res://demo/Cinematic.tscn") # Replace with your 3D game scene path

func _on_LoadGameButton_pressed():
	get_tree().change_scene_to_file("res://LoadGameScene/LoadGameScene.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()
