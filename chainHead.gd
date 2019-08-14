extends KinematicBody2D

var weaponType

func _ready():
	weaponType = "hammer"





func getWeapon():
	return weaponType
