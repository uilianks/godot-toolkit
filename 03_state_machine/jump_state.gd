# jump_state.gd
extends State

const SPEED    := 200.0
const GRAVITY  := 980.0
const JUMP_FORCE := -500.0


func enter() -> void:
	owner_node.velocity.y = JUMP_FORCE
	if owner_node.has_node("AnimationPlayer"):
		owner_node.get_node("AnimationPlayer").play("jump")


func physics_update(delta: float) -> void:
	# Gravidade
	owner_node.velocity.y += GRAVITY * delta

	# Controlo horizontal no ar
	var direction := Input.get_axis("ui_left", "ui_right")
	owner_node.velocity.x = direction * SPEED

	owner_node.move_and_slide()

	# Ao aterrar
	if owner_node.is_on_floor():
		if Input.get_axis("ui_left", "ui_right") != 0.0:
			state_machine.transition_to("walk")
		else:
			state_machine.transition_to("idle")
