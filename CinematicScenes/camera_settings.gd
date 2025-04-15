extends Node3D

func _ready():
	if not $AnimationPlayer.is_connected("animation_finished", Callable(self, "_on_animation_player_animation_finished")):
		$AnimationPlayer.connect("animation_finished", Callable(self, "_on_animation_player_animation_finished"));
	
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		$AnimationPlayer.play("scene");


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "scene":
		get_tree().change_scene_to_file("res://demo/Demo.tscn");
