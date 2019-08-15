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
var hookAttached
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
	if isIdle:
		position = player.position + Vector2(16,16)
		grappleTarget = null
		inPull = false
		
		head.position = Vector2.ZERO
		if Input.is_action_just_pressed("right_click"):
			grappleTarget = get_global_mouse_position()
			grappleOrigin = self.global_position
		if Input.is_action_just_pressed("left_click"):
			attack(head.getWeapon(), 0)
		clearChains()

	if grappleTarget:
		isIdle = false
		if (head.global_position - grappleTarget).length() > 10:
			chainVelocity = (grappleTarget - (self.global_position)).normalized() * chainSpeed
			collisionPos = head.move_and_collide(chainVelocity * delta)
			if collisionPos:
				#print(collisionPos.position)
				grappleTarget = collisionPos.position
			drawChains(head.position, (player.global_position - position) + Vector2(16,16))
		else:
			if collisionPos:
				inPull = true
				emit_signal("hook_attached", head.global_position)
				chainVelocity = Vector2.ZERO
				clearChains()
			else:
				isIdle = true

		if Input.is_action_just_pressed("ui_down"):
			grappleTarget = null
			isIdle = true
			clearChains()
			
	if inPull:
		hookAttached = true
		drawChains(head.position, (player.global_position - position) + Vector2(16,16))

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
	grappleTarget = null
	inPull = false
	hookAttached = false

