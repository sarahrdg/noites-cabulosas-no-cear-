extends Area2D

# A velocidade será controlada pelo Spawner da Fase 2
var velocity = 0 

func _process(delta: float) -> void:
	# Move para a esquerda
	position.x -= velocity
	
	# Se sair da tela, deleta para economizar memória
	if position.x < -100:
		queue_free()

# Para detectar a batida, vamos usar sinais
func _on_body_entered(body: Node2D) -> void:
	# Se o que entrou na área for o seu barco (CharacterBody2D)
	if body is CharacterBody2D:
		# Chama a função de game over que já existe no seu script world_2.gd
		get_parent().game_over()
