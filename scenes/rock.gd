extends Area2D

@export var velocity = 10

func _ready() -> void:
	var rock_regions = []
	
	var valid_y = [0, 16, 64, 80, 128]
	
	for y in valid_y:
		for x_step in range(6):
			var x = x_step * 16
			rock_regions.append(Rect2(x, y, 16, 16))
	
	if has_node("Rocks"):
		var random_region = rock_regions.pick_random()
		$Rocks.region_rect = random_region

func _process(delta: float) -> void:
	position.x -= velocity
	if position.x < -100:
		queue_free()
