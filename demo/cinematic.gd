extends Node

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):  # Space is bound to "ui_accept" by default
		get_tree().change_scene_to_file("res://demo/Demo.tscn")
