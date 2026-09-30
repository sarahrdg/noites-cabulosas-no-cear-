extends Node2D

var rock_scene = preload("res://scenes/cobra.tscn")
var bird_scene = preload("res://scenes/passaro.tscn") 

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
	var enemy 
	var screen_size = get_viewport_rect().size
	
	# Sorteio do tipo de inimigo
	if randf() > 0.5:
		enemy = rock_scene.instantiate()
	else:
		enemy = bird_scene.instantiate()

	# AUMENTANDO A DIFICULDADE:
	# Agora eles podem aparecer em QUALQUER lugar (de 50 até o final da tela - 50)
	# Isso elimina a zona segura que existia no meio.
	enemy.position.y = randf_range(50, screen_size.y - 50)
	
	enemy.position.x = screen_size.x + 100
	
	# Velocidade aumenta um pouco mais rápido agora para dificultar
	enemy.velocity = 3 + (time_elapsed * 0.7)
	
	add_child(enemy)

	# Frequência de spawn: os inimigos vão aparecer mais colados uns nos outros
	var min_spawn_time = max(0.3, 0.8 - (time_elapsed * 0.04))
	var max_spawn_time = max(0.5, 1.5 - (time_elapsed * 0.06))
	
	spawn_timer.wait_time = randf_range(min_spawn_time, max_spawn_time)

func game_over():
	get_tree().change_scene_to_file("res://scenes/ui/end_game.tscn")

func _on_hud_game_over() -> void:
	game_over()

func _on_hud_game_won() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/win_game.tscn")
