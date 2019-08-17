extends KinematicBody2D

signal hitPlayer

var ballDirection = Vector2()
var ballSpeed

#func _init(direction, speed):
#	ballDirection = direction
#	ballSpeed = speed


func _physics_process(delta):
	var collision = move_and_collide((ballDirection * ballSpeed) * delta)
	if collision:
		if collision.collider_id == 1194:
			print("collided with player")
			emit_signal("hitPlayer", 8)
			queue_free()
		else: 
			print(collision.collider)
			queue_free()
			
