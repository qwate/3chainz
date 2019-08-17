extends KinematicBody2D

signal flightDone

const GRAVITY = 20
const WALK_SPEED = 300
const jumpVelocity = 500
const downBurst = 1000
const grappleSpeed = 800

var iFrames
var stunDuration
var stunTimer
var iFrameTimer
var velocity = Vector2()
var inFlight
var targetLocal
var flightCollision
var stunned
var inIFrames

func _ready():
	inFlight = false
	stunned = false
	inIFrames = false
	iFrames = .3
	stunDuration = .1

func _physics_process(delta):
	if not stunned:
		if not inFlight:
			flightCollision = null #chasing down this bug with another hack :/ update: seems to have helped.
			#^^ this "bug" is a pain in the ass. 100% sure it is my fault, but I can't find the root cause as of now. 
			#most likely my shiiiity collision layers and not enough checks on getting the hook attached to 
			#collision shapes. might have to say "don't let perfect get in the way of good", even though I'm working with 
			#"bad" and "worse" in my case.
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
			velocity = move_and_slide(velocity, Vector2(0,-1))
				
		elif inFlight:
			#hacking a solution to the head getting stuck in walls and floors/ceilings
			if flightCollision:
				#dirty debugging
				#print("flight collision check")
				#velocity = velocity / grappleSpeed
				#position = targetLocal
				velocity = Vector2.ZERO
				inFlight = false
				targetLocal = null
				emit_signal("flightDone")
				
			elif (position - targetLocal).length() > 10:
				velocity = (targetLocal - position).normalized() * grappleSpeed
				#more dirty debugging
				#print("am I here? inFlight")
				
			else:
				velocity = velocity / grappleSpeed
				#position = targetLocal
				flightCollision = null
				inFlight = false
				emit_signal("flightDone")
			flightCollision = move_and_collide(velocity * delta)
	elif stunned:
		if stunTimer < stunDuration:
			velocity.y += GRAVITY
			stunTimer += delta
		else:
			stunned = false
			stunTimer = 0.0
	if inIFrames:
		$sprite.self_modulate = Color(1, 0, 0)
		if iFrameTimer < iFrames:
			iFrameTimer += delta
		else:
			inIFrames = false
			iFrameTimer = 0.0
	else:
		$sprite.self_modulate = Color(1, 1, 1)
func jump():
	velocity.y -= jumpVelocity

func _on_chain_hook_attached(hook_pos):
	#I should learn how to debug better
	#print("hook_pos: ", hook_pos)
	#print("global_pos: ", global_position)
	targetLocal = hook_pos
	inFlight = true
	velocity = (targetLocal - position).normalized() * grappleSpeed

#func _on_mage_playerHit(damage):
#	if not inIFrames:
#		print("Ow! I'm hurt! Took ", damage, " damage!")
#		stunned = true
#		stunTimer = 0.0
#		inIFrames = true
#		iFrameTimer = 0.0
#		emit_signal("flightDone")
#	else:
#		pass
func hit(damage):
	if not inIFrames:
		print("Ow! I'm hurt! Took ", damage, " damage!")
		stunned = true
		stunTimer = 0.0
		inIFrames = true
		iFrameTimer = 0.0
		emit_signal("flightDone")
	else:
		pass