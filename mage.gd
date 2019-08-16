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


func _ready():
	player = get_node("../../character/body")
	#playerID = get_node("../../character/body/collision").get_rid().get_id()
	#playerID = 
	#print(playerID)
	curAttack = mainAttack()
	isAlive = true
	timer = 0.0
	
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
					node.connect("hitPlayer", self, "_on_fireBall_hit_player")
					node.ballDirection = position.direction_to(player.position + Vector2(16, 16)).normalized()
					node.ballSpeed = 350
					add_child(node)
					timer = 0
			else:
				timer += delta

func mainAttack():
	return "MAIN"

func spellSpray():
	pass
	
func lazer():
	pass

func burst():
	pass

func _on_fireBall_hit_player(damage):
	emit_signal("playerHit", damage)