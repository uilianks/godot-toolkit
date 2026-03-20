class_name MovementComponent
extends Node

@export var body: CharacterBody2D
@export var speed:float = 0

func handle_movement(_delta: float) -> void:
	var direction := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()
	
	if direction != Vector2.ZERO:
		body.velocity = direction * speed
	else:
		body.velocity = body.velocity.move_toward(Vector2.ZERO, speed)
	
	body.move_and_slide()
