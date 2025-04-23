extends Node3D

func _ready():
	if not $AnimationPlayer.is_connected("animation_finished", Callable(self, "_on_animation_player_animation_finished")):
		$AnimationPlayer.connect("animation_finished", Callable(self, "_on_animation_player_animation_finished"));
	
func _physics_process(delta):
	$AnimationPlayer.play("Cinematic Entire Animation");

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Cinematic Entire Animation":
		get_tree().change_scene_to_file("res://demo/Demo.tscn");
