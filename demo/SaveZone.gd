extends Area3D

@export var ui_label: Label  # Drag UI Label aici în editor
var player_in_zone: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player_in_zone = true
		if ui_label:
			ui_label.text = "Press F to save the princess"

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		player_in_zone = false
		if ui_label:
			ui_label.text = ""

func _process(delta: float) -> void:
	if player_in_zone and Input.is_action_just_pressed("save_princess"):
		save_princess()

func save_princess() -> void:
	if ui_label:
		ui_label.text = "You saved the princess!"
	get_parent().get_node("PrincessModel").hide()
	queue_free()  # Dispare zona de salvare
