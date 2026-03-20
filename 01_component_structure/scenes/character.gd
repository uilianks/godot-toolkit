extends CharacterBody2D

@onready var movement_component: MovementComponent = $Components/MovementComponent
@onready var life_component: LifeComponent = $Components/LifeComponent
@onready var shoot_component: ShootComponent = $Components/ShootComponent

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	movement_component.handle_movement(delta)
	life_component.check_life()

func _input(event) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		shoot_component.shoot()
