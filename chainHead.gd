extends KinematicBody2D

var weaponType
var swingTime

func _ready():
	weaponType = "hammer"
	swingTime = .15





func getWeapon():
	return self
