[Component driven]

class_name MovementComponent
extends Node

@export var body: CharacterBody2D

func initialize(body: CharacterBody2D, speed: float) -> void:
	_body = body
	_speed = speed

func handle_movement(_delta: float) -> void:
	if not _body:
		return
	
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		_body.velocity.x = direction * _speed
	else:
		_body.velocity.x = move_toward(_body.velocity.x, 0, _speed)
	
	_body.move_and_slide()
