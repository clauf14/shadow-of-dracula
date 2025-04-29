extends CharacterBody3D

@export var MOVE_SPEED: float = 20.0
@export var JUMP_SPEED: float = 30.0

# stats
var curHp: int = 10
var maxHp: int = 10
var damage: int = 5
@onready var ui = $CanvasLayer/UIPlayer as Control

@export var first_person: bool = false:
	set(p_value):
		first_person = p_value
		if first_person:
			var tween: Tween = create_tween()
			tween.tween_property($CameraManager/Arm, "spring_length", 0.0, 0.33)
			tween.tween_callback($Body.set_visible.bind(false))
		else:
			$Body.visible = true
			create_tween().tween_property($CameraManager/Arm, "spring_length", 6.0, 0.33)

@export var gravity_enabled: bool = true:
	set(p_value):
		gravity_enabled = p_value
		if not gravity_enabled:
			velocity.y = 0

@export var collision_enabled: bool = true:
	set(p_value):
		collision_enabled = p_value
		$CollisionShapeBody.disabled = !collision_enabled
		$CollisionShapeRay.disabled = !collision_enabled

var current_anim: String = ""
var is_interacting: bool = false
var is_attacking: bool = false
var is_blocking: bool = false
var is_jumping: bool = false

var attackRate: float = 0.3
var lastAttackTime: int = 0

func _ready() -> void:
	ui.update_health_bar(curHp, maxHp)
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func play_anim(anim_name: String) -> void:
	if current_anim != anim_name:
		current_anim = anim_name
		$AnimationPlayer.play(anim_name)
	else:
		# Force replay if already playing
		$AnimationPlayer.play(anim_name, 0.0, 1.0, false)


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
		if not is_jumping:
			play_anim("Running_Strafe_Left" if shift_pressed else "Walking_A")
		is_moving = true

	elif Input.is_key_pressed(KEY_D):
		input_dir += %Camera3D.global_transform.basis.x
		if not is_jumping:
			play_anim("Running_Strafe_Right" if shift_pressed else "Walking_A")
		is_moving = true

	elif Input.is_key_pressed(KEY_W):
		input_dir -= %Camera3D.global_transform.basis.z
		if not is_jumping:
			play_anim("Running_A" if shift_pressed else "Walking_A")
		is_moving = true

	elif Input.is_key_pressed(KEY_S):
		input_dir += %Camera3D.global_transform.basis.z
		if not is_jumping:
			play_anim("Walking_Backwards")
		is_moving = true

	if Input.is_key_pressed(KEY_SPACE) and not is_jumping:
		velocity.y += JUMP_SPEED + MOVE_SPEED * 0.016
		is_jumping = true
		play_anim("Jump_Full_Short")

	if Input.is_key_pressed(KEY_Q):
		velocity.y -= JUMP_SPEED + MOVE_SPEED * 0.016

	if Input.is_key_pressed(KEY_KP_ADD) or Input.is_key_pressed(KEY_EQUAL):
		MOVE_SPEED = clamp(MOVE_SPEED + 0.5, 5, 9999)

	if Input.is_key_pressed(KEY_KP_SUBTRACT) or Input.is_key_pressed(KEY_MINUS):
		MOVE_SPEED = clamp(MOVE_SPEED - 0.5, 5, 9999)

	if not is_moving and not is_jumping:
		play_anim("Idle")

	return input_dir

func _input(p_event: InputEvent) -> void:
	if p_event is InputEventMouseButton and p_event.pressed:
		match p_event.button_index:
			MOUSE_BUTTON_LEFT:
				if not is_attacking and not is_interacting:
					try_attack(damage)
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
	match anim_name:
		"Interact":
			is_interacting = false
		"1H_Melee_Attack_Slice_Diagonal":
			is_attacking = false
		"Block":
			is_blocking = false
		"Jump_Full_Short":
			is_jumping = false

func try_attack(damage: int) -> void:
	if Time.get_ticks_msec() - lastAttackTime < attackRate * 1000:
		return
		
	lastAttackTime = Time.get_ticks_msec()
	is_attacking = true
	play_anim("1H_Melee_Attack_Slice_Diagonal")
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		if body and body.get_name().begins_with("Enemy") and body.has_method("take_damage"):
			body.take_damage(damage)


func get_overlapping_bodies() -> Array:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = $CollisionShape3D.shape
	query.transform = global_transform
	query.margin = 1.5
	query.collide_with_bodies = true

	var result = space_state.intersect_shape(query)
	var colliders = []
	for item in result:
		colliders.append(item.collider)
	return colliders

var is_dead: bool = false

func take_damage(damageToTake: int) -> void:
	if is_attacking or is_dead:
		return
	curHp -= damageToTake
	ui.update_health_bar(curHp, maxHp)
	if curHp <= 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	is_interacting = true

	play_anim("Death_A")
	await $AnimationPlayer.animation_finished
	var game_over_ui = preload("res://GameOver.tscn").instantiate()
	get_tree().current_scene.add_child(game_over_ui)
	await get_tree().create_timer(4).timeout
	get_tree().change_scene_to_file("res://HomeScene/HomeScene.tscn")


func _on_win_zone_body_entered(body: Node3D) -> void:
	if body.name == "Knight":  # Make sure this matches your player node's name
		var finished_game_ui = preload("res://FinishedGameScene.tscn").instantiate()
		get_tree().current_scene.add_child(finished_game_ui)
		await get_tree().create_timer(10).timeout
		get_tree().change_scene_to_file("res://HomeScene/HomeScene.tscn")
