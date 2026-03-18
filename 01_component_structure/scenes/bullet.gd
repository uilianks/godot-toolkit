class_name Bullet extends Area2D

@export var speed: float = 10000.0
const BULLET = preload("uid://8isg86pfgkhc")

func _on_body_entered(body: Node2D) -> void:
	if body.has_node("Components/PickUpComponent"):
		body.get_node("Components/PickUpComponent").pick_up_bullet(BULLET)
		queue_free()
