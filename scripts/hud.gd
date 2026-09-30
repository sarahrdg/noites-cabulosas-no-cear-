extends CanvasLayer

signal game_over
signal game_won

var total_lifes = 3
var score = 0.0
const WIN_SCORE = 30.0
var game_running = true

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if game_running:
		score += delta
		$ScoreLabel.text = "TIME: " + str(int(score))
		
		if score >= WIN_SCORE:
			game_running = false
			game_won.emit()

func _on_player_hit() -> void:
	total_lifes -= 1
	
	if total_lifes == 2:
		$Heart3.hide()
	if total_lifes == 1:
		$Heart2.hide()
	if total_lifes == 0:
		game_running = false
		game_over.emit()
