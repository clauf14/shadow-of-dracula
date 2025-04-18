extends Node3D

const CAMERA_MAX_PITCH: float = deg_to_rad(70)
const CAMERA_MIN_PITCH: float = deg_to_rad(-89.9)
const CAMERA_RATIO: float = 0.625

@export var mouse_sensitivity: float = 0.002
@export var mouse_y_inversion: float = -1.0

@onready var _camera_pitch: Node3D = %Arm
@onready var _player: CharacterBody3D = get_parent()

func _ready() -> void:
	_camera_pitch.rotation_degrees.y = 180
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(p_event: InputEvent) -> void:
	if p_event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_camera(p_event.relative)
		get_viewport().set_input_as_handled()

func rotate_camera(p_relative: Vector2) -> void:
	# Yaw: rotate player (left/right)
	_player.rotate_y(-p_relative.x * mouse_sensitivity)

	# Pitch: rotate camera arm (up/down)
	_camera_pitch.rotation.x += p_relative.y * mouse_sensitivity * CAMERA_RATIO * mouse_y_inversion
	_camera_pitch.rotation.x = clamp(_camera_pitch.rotation.x, CAMERA_MIN_PITCH, CAMERA_MAX_PITCH)
