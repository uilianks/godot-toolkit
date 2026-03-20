extends CharacterBody2D

@onready var life_component: LifeComponent = $Components/LifeComponent

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	life_component.check_life()
