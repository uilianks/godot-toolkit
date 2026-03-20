# walk_state.gd
extends State

const SPEED := 200.0


func enter() -> void:
	if owner_node.has_node("AnimationPlayer"):
		owner_node.get_node("AnimationPlayer").play("walk")


func physics_update(_delta: float) -> void:
	var input_dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up",   "ui_down")
	)

	# Normalizar para evitar velocidade diagonal maior (diagonal = sqrt(2) ≈ 1.41x)
	if input_dir.length() > 1.0:
		input_dir = input_dir.normalized()

	# Movimento nas 8 direcções
	owner_node.velocity.x = input_dir.x * SPEED
	owner_node.velocity.y = input_dir.y * SPEED

	# Virar o sprite horizontalmente
	if input_dir.x != 0.0 and owner_node.has_node("Sprite2D"):
		owner_node.get_node("Sprite2D").flip_h = input_dir.x < 0

	owner_node.move_and_slide()

	# Sem input → Idle
	if input_dir == Vector2.ZERO:
		state_machine.transition_to("idle")
