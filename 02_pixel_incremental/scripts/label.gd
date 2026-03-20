extends Label

func _ready() -> void:
	Global.pixels_alterados.connect(_atualizar)
	_atualizar()

func _atualizar() -> void:
	text = "Pixels: " + str(Global.pixels)
