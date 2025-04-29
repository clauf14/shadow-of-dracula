extends Node3D

# stats
var curHp : int = 3
var maxHp : int = 3

# attacking
var damage : int = 1
var attackDist : float = 1.5
var attackRate : float = 1.0

# physics
var moveSpeed : float = 2.5

func take_damage (damageToTake):
	curHp -= damageToTake
	# if our health reaches 0 - die
	if curHp <= 0:
		die()

# called when our health reaches 0
func die ():
	# destroy the node
	queue_free()
