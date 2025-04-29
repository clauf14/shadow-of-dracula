extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player = get_node("/root/Demo/Knight")
@onready var animation_enemy: AnimationPlayer = $AnimationPlayer

@export var MOVE_SPEED: float = 10.0
@export var ATTACK_DIST: float = 4.0
@export var ATTACK_RATE: float = 4.0
var last_attack_time: int = 0

# Stats for the enemy
var curHp: int = 15
var damage: int = 1
var is_attacking: bool = false
var is_player_in_range: bool = false

func _ready() -> void:
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(50, 10, 50)
	$DetectionArea/CollisionShape3D.shape = box_shape

	$DetectionArea.body_entered.connect(_on_body_entered)
	$DetectionArea.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	if not is_player_in_range:
		velocity = Vector3.ZERO
		move_and_slide()

		if animation_enemy.is_playing():
			animation_enemy.stop()
		return

	if is_attacking:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= ATTACK_DIST:
		velocity = Vector3.ZERO
		move_and_slide()

		if animation_enemy.is_playing() and animation_enemy.current_animation == "Walking_A":
			animation_enemy.stop()

		if not animation_enemy.is_playing() or animation_enemy.current_animation != "1H_Melee_Attack_Chop":
			animation_enemy.play("1H_Melee_Attack_Chop")

		if distance <= ATTACK_DIST and Time.get_ticks_msec() - last_attack_time > ATTACK_RATE * 1000:
			apply_damage_to_player()

		return

	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * MOVE_SPEED
	velocity.z = direction.z * MOVE_SPEED

	if not animation_enemy.is_playing() or animation_enemy.current_animation != "Walking_A":
		animation_enemy.play("Walking_A")

	move_and_slide()

	look_at(global_position - direction, Vector3.UP)

func attack() -> void:
	var now = Time.get_ticks_msec()
	if now - last_attack_time < ATTACK_RATE * 1000 or is_attacking:
		return

	is_attacking = true
	last_attack_time = now

	velocity = Vector3.ZERO
	move_and_slide()

	if animation_enemy.has_animation("1H_Melee_Attack_Chop"):
		animation_enemy.play("1H_Melee_Attack_Chop")

	if player.has_method("take_damage"):
		player.take_damage(damage)

	start_attack_cooldown()

func start_attack_cooldown() -> void:
	await get_tree().create_timer(ATTACK_RATE).timeout
	is_attacking = false

func _on_body_entered(body: Node) -> void:
	if body.name == "Knight":
		is_player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body.name == "Knight":
		is_player_in_range = false

func apply_damage_to_player() -> void:
	if player.has_method("take_damage"):
		player.take_damage(damage)
		last_attack_time = Time.get_ticks_msec()

func take_damage(damageToTake: float):
	curHp -= damageToTake
	if curHp <= 0:
		die()

func die ():
	queue_free()
