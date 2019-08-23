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
var navLayer 
var sprayTimer
var lazerData
var mainAttackArea
var mainAttackSpeed
var mainAttackTime
var mainAttackMinTime
var moveTarget
var velocity
var enemies

func _ready():
	randomize()
	mainAttackTime = 0.0
	mainAttackMinTime = 8.0
	navLayer = get_node("../Navigation2D")
	position = Vector2(512, 93)
	player = get_node("../../character/body")
	enemies = get_parent()
	curAttack = "LAZER"
	isAlive = true
	timer = 0.0
	sprayTimer = {
		"attackDuration": 7.0,
		"fireDelay": .06,
		"overallTime": 0.0,
		"sinceLast": 0.0,
		"lastDirection": Vector2(-1, -0)
	}
	lazerData = {
		"chargeDur": 3.0,
		"chargeTime": 0.0,
		"chargeCurTarget": Vector2(),
		"chargeEndTarget": Vector2(),
		"endTime": 4.0,
		"width": 5,
		"lockTime": 2
	}


func _physics_process(delta):
	playerLoc = player.global_position
	if isAlive:
		if curAttack == "SPELLSPRAY":
			if $navPreview.points:
				$navPreview.clear_points()
			if sprayTimer["overallTime"] <= sprayTimer["attackDuration"]:
				if sprayTimer["sinceLast"] >= sprayTimer["fireDelay"]:
					var node = fireBall.instance()
					#node.connect("hitPlayer", self, "_on_fireBall_hit_player")
					node.ballDirection = sprayTimer["lastDirection"].rotated(delta * 8)
					node.ballSpeed = 50
					enemies.add_child(node)
					node.global_position = self.global_position
					sprayTimer["sinceLast"] = 0.0
					sprayTimer["lastDirection"] = node.ballDirection
					sprayTimer["overallTime"] += delta
				else:
					sprayTimer["sinceLast"] += delta
					sprayTimer["lastDirection"] = sprayTimer["lastDirection"].rotated(delta * 10)
					sprayTimer["overallTime"] += delta
			else:
				curAttack = "MAIN"
				mainAttackTime = 0.0
				timer = 0.0
				print("swapping to main")
		
		elif curAttack == "LAZER":
			$navPreview.clear_points()
			lazerData["curTarget"] = to_local(player.position) + Vector2(16, 16)
			if lazerData["chargeTime"] >= lazerData["chargeDur"]:
				if lazerData["chargeTime"] < lazerData["endTime"]:
					$lazer.clear_points()
					$lazer.add_point(to_local(position))
					$lazer.add_point(lazerData["endTarget"])
					$lazer.width = 20
				elif lazerData["chargeTime"] >= lazerData["endTime"]:
					$lazer.clear_points()
					curAttack = "MAIN"
					mainAttackTime = 0.0
					timer = 0.0
					print("swapping to main")
			elif lazerData["chargeTime"] < lazerData["chargeDur"]:
				if lazerData["chargeTime"] < lazerData["lockTime"]:
					lazerData["endTarget"] = lazerData["curTarget"]
					$lazer.clear_points()
					$lazer.add_point(to_local(position))
					$lazer.add_point(lazerData["curTarget"])
					$lazer.width = lazerData["width"]
				elif lazerData["chargeTime"] > lazerData["lockTime"]:
					$lazer.clear_points()
					$lazer.add_point(to_local(position))
					$lazer.add_point(lazerData["endTarget"])
					lazerData["width"] += 5 * delta
					$lazer.width = lazerData["width"]
			lazerData["chargeTime"] += delta
				
		elif curAttack == "MAIN":
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
					enemies.add_child(node)
					node.global_position = self.global_position
					timer = 0.0
			else:
				timer += delta
			
			if mainAttackMinTime < mainAttackTime:
				var swapAttackRoll = randi() % 100
				if swapAttackRoll <= 2:
					print("rolling! rolled: ", swapAttackRoll)
					sprayTimer = {
						"attackDuration": 7.0,
						"fireDelay": .04,
						"overallTime": 0.0,
						"sinceLast": 0.0,
						"lastDirection": Vector2(-1, -0)
					}
					curAttack = "SPELLSPRAY"
					print("swapping to spray")
				elif swapAttackRoll > 2 and swapAttackRoll <= 4:
					lazerData = {
						"chargeDur": 3.0,
						"chargeTime": 0.0,
						"chargeCurTarget": Vector2(),
						"chargeEndTarget": Vector2(),
						"endTime": 4.0,
						"width": 5,
						"lockTime": 2
					}
					curAttack = "LAZER"
					print("swapping to lazer")
			else:
				mainAttackTime += delta
			
			$navPreview.clear_points()
			if position.distance_to(player.position) > 200:
				var path = navLayer.get_simple_path(position, player.position + Vector2(16, 16))
				if path.size() > 0:
					for i in range(0, path.size()):
						$navPreview.add_point(to_local(path[i]))
				if position.distance_to(path[1]) < 5:
					position = path[1]
					path.remove(1)
				position += position.direction_to(path[1]) * delta * 100
			elif position.distance_to(player.position) < 100:
				position = lerp(position, player.position, delta * -1)


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