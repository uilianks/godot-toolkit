class_name LifeComponent extends Node

@export var character: CharacterBody2D
@export var health_bar: ProgressBar
@export var health_label: Label

func check_life():
	health_label.text = str(character.life)
	health_bar.value = character.life

func _take_damage() -> void:
	var amount = 10
	character.life -= amount
	character.life = max(character.life, 0)
	check_if_alive()
	check_life()

func check_if_alive():
	if character.life <= 0:
		print('died')
		character.queue_free()
	else:
		print('still alive')

func take_damage(amount: int) -> void:
	character.life -= amount
	character.life = max(character.life, 0)
	check_life()
	check_if_alive()  # ← faltava isso
