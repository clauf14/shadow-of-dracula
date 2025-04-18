extends CharacterBody3D

@export var MOVE_SPEED: float = 20.0
@export var JUMP_SPEED: float = 2.0
@export var first_person: bool = false : 
	set(p_value):
		first_person = p_value
		if first_person:
			var tween: Tween = create_tween()
			tween.tween_property($CameraManager/Arm, "spring_length", 0.0, .33)
			tween.tween_callback($Body.set_visible.bind(false))
		else:
			$Body.visible = true
			create_tween().tween_property($CameraManager/Arm, "spring_length", 6.0, .33)

@export var gravity_enabled: bool = true :
	set(p_value):
		gravity_enabled = p_value
		if not gravity_enabled:
			velocity.y = 0

@export var collision_enabled: bool = true :
	set(p_value):
		collision_enabled = p_value
		$CollisionShapeBody.disabled = !collision_enabled
		$CollisionShapeRay.disabled = !collision_enabled

var current_anim: String = ""
var is_interacting: bool = false
var is_attacking: bool = false
var is_blocking: bool = false

func _ready() -> void:
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func play_anim(anim_name: String) -> void:
	if current_anim != anim_name:
		current_anim = anim_name
		$AnimationPlayer.play(anim_name)

func _physics_process(p_delta) -> void:
	if is_interacting or is_attacking or is_blocking:
		return

	var direction: Vector3 = get_camera_relative_input()
	var h_veloc: Vector2 = Vector2(direction.x, direction.z).normalized() * MOVE_SPEED

	if Input.is_key_pressed(KEY_SHIFT):
		h_veloc *= 2

	velocity.x = h_veloc.x
	velocity.z = h_veloc.y

	if gravity_enabled:
		velocity.y -= 40 * p_delta

	move_and_slide()

func get_camera_relative_input() -> Vector3:
	var input_dir: Vector3 = Vector3.ZERO
	var is_moving := false
	var shift_pressed := Input.is_key_pressed(KEY_SHIFT)

	if is_interacting or is_attacking or is_blocking:
		return input_dir

	if Input.is_key_pressed(KEY_A):
		input_dir -= %Camera3D.global_transform.basis.x
		play_anim("Running_Strafe_Left" if shift_pressed else "Walking_A")
		is_moving = true

	elif Input.is_key_pressed(KEY_D):
		input_dir += %Camera3D.global_transform.basis.x
		play_anim("Running_Strafe_Right" if shift_pressed else "Walking_A")
		is_moving = true

	elif Input.is_key_pressed(KEY_W):
		input_dir -= %Camera3D.global_transform.basis.z
		play_anim("Running_A" if shift_pressed else "Walking_A")
		is_moving = true

	elif Input.is_key_pressed(KEY_S):
		input_dir += %Camera3D.global_transform.basis.z
		play_anim("Walking_Backwards")
		is_moving = true

	if Input.is_key_pressed(KEY_SPACE):
		velocity.y += JUMP_SPEED + MOVE_SPEED * 0.016
	if Input.is_key_pressed(KEY_Q):
		velocity.y -= JUMP_SPEED + MOVE_SPEED * 0.016
	if Input.is_key_pressed(KEY_KP_ADD) or Input.is_key_pressed(KEY_EQUAL):
		MOVE_SPEED = clamp(MOVE_SPEED + 0.5, 5, 9999)
	if Input.is_key_pressed(KEY_KP_SUBTRACT) or Input.is_key_pressed(KEY_MINUS):
		MOVE_SPEED = clamp(MOVE_SPEED - 0.5, 5, 9999)

	if not is_moving:
		play_anim("Idle")

	return input_dir

func _input(p_event: InputEvent) -> void:
	if p_event is InputEventMouseButton and p_event.pressed:
		match p_event.button_index:
			MOUSE_BUTTON_LEFT:
				if not is_attacking and not is_interacting:
					is_attacking = true
					play_anim("1H_Melee_Attack_Slice_Horizontal")
			MOUSE_BUTTON_RIGHT:
				if not is_blocking and not is_interacting:
					is_blocking = true
					play_anim("Block")

	elif p_event is InputEventKey:
		if p_event.pressed:
			match p_event.keycode:
				KEY_V:
					first_person = !first_person
				KEY_G:
					gravity_enabled = !gravity_enabled
				KEY_C:
					collision_enabled = !collision_enabled
				KEY_E:
					if not is_interacting and not is_attacking and not is_blocking:
						is_interacting = true
						play_anim("Interact")

		elif p_event.keycode in [KEY_Q, KEY_SPACE]:
			velocity.y = 0

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "Interact":
		is_interacting = false
	elif anim_name == "1H_Melee_Attack_Slice_Horizontal":
		is_attacking = false
	elif anim_name == "Block":
		is_blocking = false
