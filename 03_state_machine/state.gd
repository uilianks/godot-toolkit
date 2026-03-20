# state.gd
# Classe base. Cada estado herda daqui.

class_name State
extends Node

# Referência ao StateMachine pai (preenchida automaticamente)
var state_machine: StateMachine = null

# Referência ao dono (player, enemy, etc.) — podes definir no _ready de cada estado
var owner_node: CharacterBody2D = null


func _ready() -> void:
	# O dono é o avô deste nó (Player → StateMachine → Estado)
	owner_node = get_parent().get_parent() as CharacterBody2D


# Chamado ao entrar no estado
func enter() -> void:
	pass

# Chamado ao sair do estado
func exit() -> void:
	pass

# Chamado em _process
func update(_delta: float) -> void:
	pass

# Chamado em _physics_process
func physics_update(_delta: float) -> void:
	pass
