extends Node2D

var rock_scene = preload("res://scenes/rock.tscn")
var spawn_timer : Timer
var time_elapsed : float = 0.0

func _ready() -> void:
	$HUD.game_won.connect(_on_hud_game_won)
	
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 1.5
	spawn_timer.connect("timeout", _on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start()

func _process(delta: float) -> void:
	time_elapsed += delta

func _on_spawn_timer_timeout() -> void:
	var rock = rock_scene.instantiate()
	var screen_size = get_viewport_rect().size

	rock.position.x = screen_size.x + 100

	rock.position.y = randf_range(50, screen_size.y - 50)
	
	rock.velocity = 2 + (time_elapsed * 0.5)
	
	add_child(rock)

	var min_spawn_time = max(0.4, 1.0 - (time_elapsed * 0.03))
	var max_spawn_time = max(0.6, 2.0 - (time_elapsed * 0.05))
	
	spawn_timer.wait_time = randf_range(min_spawn_time, max_spawn_time)

func game_over():
	get_tree().change_scene_to_file("res://scenes/ui/end_game.tscn")

func _on_hud_game_over() -> void:
	game_over()

func _on_hud_game_won() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/level_complete.tscn")
