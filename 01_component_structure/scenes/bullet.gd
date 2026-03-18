class_name Bullet
extends Area2D

@export var speed: float = 10000.0
@export var damage: int = 10
var shooter: Node

func _on_body_entered(body: Node2D) -> void:
	if body == shooter:
		return
	if body.has_node("Components/PickUpComponent"):
		body.get_node("Components/PickUpComponent").pick_up_bullet(preload("uid://8isg86pfgkhc"))
		queue_free()
	if body.has_node("Components/LifeComponent"):
		body.get_node("Components/LifeComponent").take_damage(damage)
		queue_free()
