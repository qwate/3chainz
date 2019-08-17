extends KinematicBody2D
signal playerHit

var isAlive
var player
var playerID
var curAttack
var followStyle
var timer
var playerLoc = Vector2()
var attackTimer = Vector2()
var fireBall = preload("res://fireBall.tscn")
var sprayTimer
var burstData
var mainAttackArea
var mainAttackSpeed

func _ready():
	position = Vector2(512, 93)
	player = get_node("../../character/body")
	curAttack = "SPELLSPRAY"
	isAlive = true
	timer = 0.0
	sprayTimer = {
		"attackDuration": 7.0,
		"fireDelay": .04,
		"overallTime": 0.0,
		"sinceLast": 0.0,
		"lastDirection": Vector2(-1, -0)
	}
#	mainAttackArea = RectangleShape2D.new()
#	#mainAttackArea.position = Vector2(0,0)
#	mainAttackArea.extents = Vector2(480, 272)
#	mainAttackSpeed = 200
#	var shape_owner = create_shape_owner(self)
#	shape_owner_add_shape(shape_owner, mainAttackArea)
	#mainAttackArea.position = Vector2(0, 0)
	
#	burstData = {
#		"pulses": 4,
#		"perPulse": 2,
#		"interpulseDelay": .03,
#		"pulseDelay": .3,
#		"interpulseTimer": 0.0,
#		"pulseTimer": 0.0,
#		"curPulse" : 0
#	}
	
func _physics_process(delta):
	playerLoc = player.global_position
	if isAlive:
		if curAttack == "MAIN":
			if timer > 1:
				var space_state = get_world_2d().direct_space_state
				var result = space_state.intersect_ray(global_position, (player.position), [self])
				if result:
					pass
				else:
					var node = fireBall.instance()
					#node.connect("hitPlayer", self, "_on_fireBall_hit_player")
					node.ballDirection = position.direction_to(player.position + Vector2(16, 16)).normalized()
					node.ballSpeed = 350
					add_child(node)
					timer = 0
			else:
				timer += delta
		
		elif curAttack == "SPELLSPRAY":
			if sprayTimer["overallTime"] <= sprayTimer["attackDuration"]:
				if sprayTimer["sinceLast"] >= sprayTimer["fireDelay"]:
					var node = fireBall.instance()
					#node.connect("hitPlayer", self, "_on_fireBall_hit_player")
					node.ballDirection = sprayTimer["lastDirection"].rotated(delta * 8)
					node.ballSpeed = 50
					add_child(node)
					sprayTimer["sinceLast"] = 0.0
					sprayTimer["lastDirection"] = node.ballDirection
					sprayTimer["overallTime"] += delta
				else:
					sprayTimer["sinceLast"] += delta
					sprayTimer["lastDirection"] = sprayTimer["lastDirection"].rotated(delta * 8)
					sprayTimer["overallTime"] += delta
			else:
				sprayTimer["sinceLast"] = 0.0
				sprayTimer["lastDirection"] = Vector2(-1, 0)
				sprayTimer["overallTime"] += 0.0
				curAttack = "MAIN"

func mainAttack():
	pass

func spellSpray():
	pass
	
func lazer():
	pass

func burst():
	pass
	
func _on_fireBall_hit_player(damage):
	emit_signal("playerHit", damage)