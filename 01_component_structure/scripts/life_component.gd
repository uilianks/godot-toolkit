class_name LifeComponent extends Node

@export var life: int = 0
@export var character: CharacterBody2D
@export var health_bar: ProgressBar
@export var health_label: Label

func check_life():
	health_label.text = str(life)
	health_bar.value = life

func _take_damage() -> void:
	var amount = 10
	life -= amount
	life = max(life, 0)
	check_if_alive()
	check_life()

func check_if_alive():
	if life <= 0:
		print('died')
		character.queue_free()
	else:
		print('still alive')

func take_damage(amount: int) -> void:
	life -= amount
	life = max(life, 0)
	check_life()
	check_if_alive()  # ← faltava isso
