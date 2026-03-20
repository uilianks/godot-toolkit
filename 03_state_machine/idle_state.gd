# idle_state.gd
extends State

const SPEED := 200.0

func enter() -> void:
	if owner_node.has_node("AnimationPlayer"):
		owner_node.get_node("AnimationPlayer").play("idle")


func physics_update(_delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0.0:
		state_machine.transition_to("walk")
		return

	# Se pressionar salto → Jump
	if Input.is_action_just_pressed("ui_accept") and owner_node.is_on_floor():
		state_machine.transition_to("jump")
