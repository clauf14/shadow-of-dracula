
extends Area2D

var player_in_range = false
@onready var ui_label = get_node("/root/Main/CanvasLayer/Label") # Schimbă calea dacă e altundeva

func _on_body_entered(body):
	if body.name == "Player": # sau cum ai numit caracterul tău
		player_in_range = true
		ui_label.text = "Press E to save the princess"
		ui_label.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		ui_label.visible = false

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("ui_accept"): # E sau ce vrei tu
		ui_label.text = "Congratulations! You saved the princess!"
