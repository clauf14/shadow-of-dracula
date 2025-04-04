extends CharacterBody3D

# stats
var curHp : int = 10
var maxHp : int = 10
var damage : int = 1

var gold : int = 0

# physics	
var moveSpeed : float = 5.0
var jumpForce : float = 10.0
var gravity : float = 15.0

# components
@onready var weapon = $Weapon as Node3D
@onready var camera = $CameraOrbit as Node3D
@onready var ui = $CanvasLayer/UI as Control

# called when the node is initialized
func _ready ():	
	# initialize the UI
	ui.update_health_bar(curHp, maxHp)
	ui.update_gold_text(gold)

# called every physics step (60 times a second)
func _physics_process (delta):
	
	velocity.x = 0
	velocity.z = 0
	
	var input = Vector3()
	
	input.z = Input.get_axis("move_backwards","move_forwards")
	input.x = Input.get_axis("move_right","move_left")
	
	# normalize the input vector to prevent increased diagonal speed
	input = input.normalized()
	
	# get the relative direction
	var dir = (transform.basis.z * input.z + transform.basis.x * input.x)
	
	# apply the direction to our velocity
	velocity.x = dir.x * moveSpeed
	velocity.z = dir.z * moveSpeed
	
	# gravity
	velocity.y -= gravity * delta
	
	# jump input
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jumpForce
		
	# attack input
	if Input.is_action_just_pressed("attack"):
		weapon.try_attack("Enemy", damage)
	
	# move along the current velocity
	move_and_slide()


# called when we collect a coin
func give_gold (amount):
	
	gold += amount
	
	# update the UI
	ui.update_gold_text(gold)

# called when an enemy deals damage to us
func take_damage (damageToTake):
	
	curHp -= damageToTake
	
	# update the UI
	ui.update_health_bar(curHp, maxHp)
	
	# if our health is 0, die
	if curHp <= 0:
		die()

# called when our health reaches 0
func die ():
	
	# reload the scene
	get_tree().reload_current_scene()
