extends Node2D

func _ready() -> void:
	_criar_paredes()

func _criar_paredes() -> void:
	var tamanho = get_viewport().get_visible_rect().size
	
	# [posição central, tamanho da parede]
	var paredes = [
		# Chão
		[Vector2(tamanho.x / 2, tamanho.y), Vector2(tamanho.x, 20)],
		# Teto
		[Vector2(tamanho.x / 2, 0),         Vector2(tamanho.x, 20)],
		# Parede esquerda
		[Vector2(0, tamanho.y / 2),          Vector2(20, tamanho.y)],
		# Parede direita
		[Vector2(tamanho.x, tamanho.y / 2),  Vector2(20, tamanho.y)],
	]
	
	for p in paredes:
		var body = StaticBody2D.new()
		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		
		rect.size = p[1]
		shape.shape = rect
		body.position = p[0]
		body.add_child(shape)
		add_child(body)
