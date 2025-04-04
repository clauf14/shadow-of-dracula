extends Area3D

@export var goldToGive := 1
var rotateSpeed := 5.0

# called every frame
func _process (delta):
	# rotate along the Y axis
	rotate_y(rotateSpeed * delta)
	
# called when a body enters the coin collider
func on_collision(body):
	# is this the player? If so give them gold
	if body.name == "Player":
		body.give_gold(goldToGive)
		queue_free()
