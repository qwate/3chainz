extends KinematicBody2D

signal flightDone

const GRAVITY = 20
const WALK_SPEED = 300
const jumpVelocity = 500
const downBurst = 1000
const grappleSpeed = 800

var velocity = Vector2()
var inFlight
var targetLocal

func _ready():
	inFlight = false
	
func _physics_process(delta):
	if not inFlight:
		if Input.is_action_pressed("ui_left"):
			velocity.x = -WALK_SPEED
		elif Input.is_action_pressed("ui_right"):
			velocity.x = WALK_SPEED
		else:
			velocity.x = velocity.x * .8
			if abs(velocity.x) < 10:
				velocity.x = 0
		
		if is_on_floor():
			velocity.y = 0
			if Input.is_action_pressed("ui_up"):
				jump()
		else:
			velocity.y += GRAVITY
			if Input.is_action_just_pressed("ui_down"):
				velocity.y += downBurst
			
		if is_on_ceiling():
			if velocity.y < 0:
				velocity.y = GRAVITY
		if is_on_wall():
			velocity.x = 0
			
	elif inFlight:
		if (position - targetLocal).length() > 20:
			velocity = (targetLocal - position).normalized() * grappleSpeed
		else:
			velocity = velocity / grappleSpeed
			inFlight = false
			position = targetLocal
			emit_signal("flightDone")
	move_and_slide(velocity, Vector2(0,-1))



func jump():
	velocity.y -= jumpVelocity

func _on_chain_hook_attached(hook_pos):
	print("hook_pos: ", hook_pos)
	print("global_pos: ", global_position)
	targetLocal = hook_pos
	inFlight = true
	
