# state_machine.gd
# Attach this script to a Node inside your player (e.g. a child Node named "StateMachine")
# Usage: add State nodes as children of this node.

class_name StateMachine
extends Node

@export var initial_state: State  # Arrastar o estado inicial no Inspector

var current_state: State
var states: Dictionary = {}


func _ready() -> void:
	# Registar todos os estados filhos
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self

	# Iniciar no estado inicial
	if initial_state:
		current_state = initial_state
		current_state.enter()


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func transition_to(state_name: String) -> void:
	if not states.has(state_name):
		push_error("State '%s' not found in StateMachine!" % state_name)
		return

	if current_state:
		current_state.exit()

	current_state = states[state_name]
	current_state.enter()
	print("→ Transição para estado: ", state_name)
