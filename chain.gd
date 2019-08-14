extends KinematicBody2D

const chainSpeed = 400
var head
var chainLinks
var chainVelocity = Vector2()
var grappleTarget = Vector2()
var grappleOrigin = Vector2()
var isIdle
var inCombo


func _ready():
	isIdle = true
	inCombo = false
	head = $chainHead
	chainLinks = $chainLinks
	
	
func _physics_process(delta):
	#Getting inputs relevant to the chain and its hook. Starting with actions while idle (not in 
	#the process of grappling or attacking)
	if isIdle:
		grappleTarget = null
		head.position = Vector2.ZERO
		if Input.is_action_just_pressed("right_click"):
			grappleTarget = get_global_mouse_position()
			grappleOrigin = self.global_position
		if Input.is_action_just_pressed("left_click"):
			attack(head.getWeapon())
		
	
	if grappleTarget:
		isIdle = false
		if (head.global_position - grappleTarget).length() > 10:
			chainVelocity = (grappleTarget - (self.global_position)).normalized() * chainSpeed
			#chainVelocity = (grappleTarget - grappleOrigin).normalized() * chainSpeed
			var collisionPos = head.move_and_collide(chainVelocity * delta)
			if collisionPos:
				print(collisionPos.position)
				grappleTarget = collisionPos.position
			drawChains(head.position, Vector2.ZERO)
		else:
			grappleTarget = null
			isIdle = true
			chainVelocity = Vector2.ZERO
			clearChains()
			
			
		
			
func drawChains(headEnd, playerEnd):
	if chainLinks.get_point_count() < 2:
		chainLinks.clear_points()
		chainLinks.add_point(headEnd)
		chainLinks.add_point(playerEnd)
	else:
		chainLinks.set_point_position(0, headEnd)
		chainLinks.set_point_position(1, playerEnd)
func clearChains():
	chainLinks.clear_points()
	
func attack(weapon):
	pass
	
		
	
	
	

























#const chainSpeed = 200
#var isIdle = true
#var isShooting = false
#var target = Vector2()
#var chainPos = Vector2()
#var chainVelocity = Vector2()
#
#func _ready():
#	isIdle = true
#	isShooting = false
#	$chainHead.position = self.global_position
#
#
#func _physics_process(delta):
#	if Input.is_action_just_pressed("right_click"):
#		#createLine(get_global_mouse_position(), Vector2.ZERO)
#		shootChain(get_global_mouse_position())
#	if isShooting:
#		if ($chainHead.position - target).length() < 10:
#			$chainHead.position = target
#			chainVelocity = Vector2.ZERO
#			isShooting = false
#			isIdle = true
#
#			$chainHead.position = position
#		else:
#			chainVelocity = (target - $chainHead.position).normalized() * chainSpeed
#			$chainHead.move_and_slide(chainVelocity)
#			createLine($chainHead.position, Vector2.ZERO)
#	elif not isShooting:
#		removeLine()
#		$chainHead.position = position
#
#
#func createLine(from, to):
#	if $Line2D.get_point_count() < 2:
#		$Line2D.clear_points()
#		$Line2D.add_point(from - self.global_position)
#		$Line2D.add_point(to)
#	else:
#		$Line2D.set_point_position(0, from - self.global_position)
#		$Line2D.set_point_position(1, to)
#func shootChain(to):
#	target = to
#	isIdle = false
#	isShooting = true
#
#
#func removeLine():
#	$Line2D.clear_points()
