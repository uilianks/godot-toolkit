class_name ShootComponent
extends Node

@export var bullet: PackedScene
@export var body: CharacterBody2D

func shoot() -> void:
	if not bullet:
		print('no bullet loaded')
		return
	var instance: Bullet = bullet.instantiate()
	instance.global_position = body.global_position
	
	var direction := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()
	
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	
	body.get_parent().add_child(instance)
	
	var tween = instance.create_tween()
	tween.tween_property(instance, "position", 
		instance.position + direction * 1000, 
		1000.0 / instance.speed)
	tween.tween_callback(instance.queue_free)
