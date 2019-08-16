extends KinematicBody2D

var player
var curAttack
var playerLoc

func _ready():
	player = get_node("../../character")
	curAttack = $attackAnimations/mainAttack
func _physics_process(delta):
	playerLoc = player.global_position
	