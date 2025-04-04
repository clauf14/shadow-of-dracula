extends Node3D

var attackRate : float = 0.3
var lastAttackTime : int = 0

@onready var shape_cast = $Sword/ShapeCast3D as ShapeCast3D
@onready var animation_player = $AnimatonPlayer as AnimationPlayer

# called when we press the attack button
func try_attack (name, damage):

	# if we're not ready to attack, return
	if Time.get_ticks_msec() - lastAttackTime < attackRate * 1000:
		return
		
	# set the last attack time to now
	lastAttackTime = Time.get_ticks_msec()
	
	# play the animation
	animation_player.stop()
	animation_player.play("attack")
	
	# is the ray cast colliding with an enemy?
	if shape_cast.is_colliding():
		for i in range(shape_cast.get_collision_count()):
			var collider = shape_cast.get_collider(i)
			var is_target = (collider.get_name() == name)
			var has_method = collider.has_method("take_damage")
			if is_target and has_method:
				collider.take_damage(damage)
