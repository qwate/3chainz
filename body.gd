extends KinematicBody2D

const GRAVITY = 20
const WALK_SPEED = 300
const jumpVelocity = 500
const downBurst = 1000

var velocity = Vector2()


func _physics_process(delta):

	if Input.is_action_pressed("ui_left"):
		velocity.x = -WALK_SPEED
	elif Input.is_action_pressed("ui_right"):
		velocity.x = WALK_SPEED
	else:
		velocity.x = velocity.x * (50 * delta)
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
		
	move_and_slide(velocity, Vector2(0,-1))

func _ready():
	pass

func jump():
	velocity.y -= jumpVelocity

	
	
	
