extends CharacterBody3D

# stats
var curHp : int = 3
var maxHp : int = 3

# attacking
var damage : int = 1
var attackDist : float = 1.5
var attackRate : float = 1.0

# physics
var moveSpeed : float = 2.5

# components
@onready var timer = $Timer as Timer
@onready var player = get_node("/root/MainScene/Player") as CharacterBody3D
@onready var weapon = $Weapon
func _ready ():
	
	# set the timer wait time
	timer.wait_time = attackRate
	timer.start()

# called 60 times a second
func _physics_process (_delta):
	
	# get the distance from us to the player
	var dist = position.distance_to(player.position)
	
	# if we're outside of the attack distance, chase after the player
	if dist > attackDist:
		# calculate the direction between us and the player
		var dir = (player.position - position).normalized()
		
		velocity.x = dir.x
		velocity.y = 0
		velocity.z = dir.z
		
		# move towards the player
		move_and_slide()
		
		look_at(transform.origin - velocity, Vector3.UP)

# called every "attackRate" seconds
func on_timeout():
	# if we're within the attack distance - attack the player
	if position.distance_to(player.position) <= attackDist:
		weapon.try_attack("Player", damage)
	#	player.take_damage(damage)

# called when the player deals damage to us
func take_damage (damageToTake):
	curHp -= damageToTake
	# if our health reaches 0 - die
	if curHp <= 0:
		die()

# called when our health reaches 0
func die ():
	# destroy the node
	queue_free()
