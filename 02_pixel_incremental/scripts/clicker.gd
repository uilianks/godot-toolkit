extends Button

@onready var simulacao: Node2D = $"../Simulacao"

func _on_pressed() -> void:
	simulacao.adicionar_pixels(100, global_position)
