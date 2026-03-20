extends RigidBody2D

var tempo := 0.0
var dancando := true
var passo_atual := 0
var passos := []
var duracao_passo := 0.0
var destino = Vector2(300, 400)  # coloca aqui as coordenadas que quiseres
# Parâmetros do passo atual
var freq_x := 0.0
var freq_y := 0.0
var amp_x := 0.0
var amp_y := 0.0
var fase := 0.0

func launch(initial_velocity: Vector2) -> void:
	gravity_scale = 0
	freeze = true
	# apaga esta linha: destino = Vector2(randf_range(100, 800), randf_range(100, 500))
	
	var total_passos = randi_range(3, 7)
	for i in range(total_passos):
		passos.append(_gerar_passo())
	
	_iniciar_passo()

func _gerar_passo() -> Dictionary:
	var tipos = ["senoidal", "circular", "tremor", "espiral", "oito"]
	return {
		"tipo": tipos[randi() % tipos.size()],
		"duracao": randf_range(0.4, 1.2),
		"freq_x": randf_range(2.0, 8.0),
		"freq_y": randf_range(2.0, 8.0),
		"amp_x":  randf_range(30.0, 150.0),
		"amp_y":  randf_range(30.0, 150.0),
		"fase":   randf_range(0.0, TAU),
	}

func _iniciar_passo() -> void:
	if passo_atual >= passos.size():
		dancando = false
		return
	
	var p = passos[passo_atual]
	duracao_passo = p["duracao"]
	freq_x = p["freq_x"]
	freq_y = p["freq_y"]
	amp_x  = p["amp_x"]
	amp_y  = p["amp_y"]
	fase   = p["fase"]
	tempo  = 0.0

func _process(delta: float) -> void:
	tempo += delta
	
	if dancando:
		var p = passos[passo_atual]
		var offset := Vector2.ZERO
		
		match p["tipo"]:
			"senoidal":
				# Onda suave em X e Y
				offset.x = sin(tempo * freq_x + fase) * amp_x
				offset.y = cos(tempo * freq_y + fase) * amp_y
			
			"circular":
				# Gira em círculo
				offset.x = cos(tempo * freq_x + fase) * amp_x
				offset.y = sin(tempo * freq_x + fase) * amp_x
			
			"tremor":
				# Vibração rápida e nervosa
				offset.x = sin(tempo * freq_x * 3.0 + fase) * amp_x * 0.4
				offset.y = cos(tempo * freq_y * 3.0 + fase) * amp_y * 0.4
			
			"espiral":
				# Espiral que cresce
				var r = (tempo / duracao_passo) * amp_x
				offset.x = cos(tempo * freq_x + fase) * r
				offset.y = sin(tempo * freq_y + fase) * r
			
			"oito":
				# Figura de oito (lemniscata)
				offset.x = sin(tempo * freq_x + fase) * amp_x
				offset.y = sin(tempo * freq_y * 2.0 + fase) * amp_y * 0.5
		
		position += offset * delta
		
		# Avança para o próximo passo
		if tempo >= duracao_passo:
			passo_atual += 1
			_iniciar_passo()
	
	else:
		# Vai para o destino
		global_position = global_position.lerp(destino, delta * 3.0)
		if global_position.distance_to(destino) < 2.0:
			global_position = destino
			Global.pixels += 1
			Global.emit_signal("pixels_alterados")
			set_process(false)
