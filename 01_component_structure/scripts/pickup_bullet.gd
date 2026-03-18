class_name PickUpComponent
extends Node

@export var shoot_component: ShootComponent

func pick_up_bullet(bullet: PackedScene) -> void:
	shoot_component.bullet = bullet
