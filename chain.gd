extends KinematicBody2D

signal hook_attached

const chainSpeed = 400
const attackSpeed = 1000
var head
var chainLinks
var chainVelocity = Vector2()
var grappleTarget = Vector2()
var grappleOrigin = Vector2()
var isIdle
var inCombo
var inPull
var player
var comboTimer = Vector2()
var attackDirection = Vector2()
var attackVelocity = Vector2()
var collisionPos = Vector2()


func _ready():
	isIdle = true
	inCombo = false
	inPull = false
	head = $chainHead
	chainLinks = $chainLinks
	player = get_node('../body')

func _physics_process(delta):
	#Getting inputs relevant to the chain and its hook. Starting with actions while idle (not in 
	#the process of grappling or attacking)
	if isIdle:
		position = player.position + Vector2(16,16)
		grappleTarget = null
		head.position = Vector2.ZERO
		if Input.is_action_just_pressed("right_click"):
			grappleTarget = get_global_mouse_position()
			grappleOrigin = self.global_position
		if Input.is_action_just_pressed("left_click"):
			attack(head.getWeapon(), 0)
		clearChains()

	if grappleTarget:
		isIdle = false
		if (head.global_position - grappleTarget).length() > 5:
			chainVelocity = (grappleTarget - (self.global_position)).normalized() * chainSpeed
			#chainVelocity = (grappleTarget - grappleOrigin).normalized() * chainSpeed
			collisionPos = head.move_and_collide(chainVelocity * delta)
			if collisionPos:
				#print(collisionPos.position)
				grappleTarget = collisionPos.position
			drawChains(head.position, (player.global_position - position) + Vector2(16,16))
		else:
			if collisionPos:
				inPull = true
				chainVelocity = Vector2.ZERO
				clearChains()
			else:
				isIdle = true
				
		
		if Input.is_action_just_pressed("ui_down"):
			grappleTarget = null
			isIdle = true
			clearChains()
			
	if inPull:
		emit_signal("hook_attached", head.global_position)
		inPull = false

	if inCombo:
		position = player.position + Vector2(16,16)
		comboTimer.x += delta
		if comboTimer.y - comboTimer.x <= 0:
			inCombo = false
			isIdle = true
		else:
			attackVelocity = attackDirection.normalized() * (chainSpeed * 1.5)
			head.move_and_slide(attackVelocity)
			drawChains(head.position, self.global_position - position)
			#print(attackVelocity)


func drawChains(headEnd, playerEnd):
	if chainLinks.get_point_count() < 2:
		clearChains()
		chainLinks.add_point(headEnd)
		chainLinks.add_point(playerEnd)
	else:
		chainLinks.set_point_position(0, headEnd)
		chainLinks.set_point_position(1, playerEnd)
		
func clearChains():
	chainLinks.clear_points()
	
func attack(weapon, comboIndex):
	isIdle = false
	inCombo = true
	attackDirection = get_global_mouse_position() - self.global_position
	comboTimer = Vector2(0.0, weapon.swingTime) 



func _on_body_flightDone():
	isIdle = true

























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



