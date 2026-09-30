extends Area2D

@export var velocity = 10

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	position.x -= velocity
	if position.x < -100:
		queue_free()
