extends CharacterBody2D
signal hit

@export var speed := 400.0

const MAP_BOUNDS := Rect2(
	Vector2(-300, -450),     
	Vector2(1300, 900)  
)

var hit_sound_player: AudioStreamPlayer

func _ready() -> void:
	hit_sound_player = AudioStreamPlayer.new()
	hit_sound_player.stream = preload("res://assets/musics/fah.mp3")
	add_child(hit_sound_player)

func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	
	move_and_slide()
	_limit_to_map()
	
	if velocity == Vector2.ZERO:
		$Ship/AnimationPlayer.play("idle")

func _limit_to_map() -> void:
	var sprite: Sprite2D = $Ship
	var sprite_size = sprite.texture.get_size() * sprite.scale

	var min_x = MAP_BOUNDS.position.x + sprite_size.x / 2
	var max_x = MAP_BOUNDS.position.x + MAP_BOUNDS.size.x - sprite_size.x / 2

	var min_y = MAP_BOUNDS.position.y + sprite_size.y / 2
	var max_y = MAP_BOUNDS.position.y + MAP_BOUNDS.size.y - sprite_size.y / 2

	position.x = clamp(position.x, min_x, max_x)
	position.y = clamp(position.y, min_y, max_y)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		$Ship/AnimationPlayer.play("walk_foward")
	elif event.is_action_pressed("ui_up"):
		$Ship/AnimationPlayer.play("walk_up")
	elif event.is_action_pressed("ui_down"):
		$Ship/AnimationPlayer.play("walk_down")
	elif event.is_action_pressed("ui_left"):
		$Ship/AnimationPlayer.play("walk_left")

func play_hit_animation() -> void:
	var sprite = $Ship
	var tween = create_tween()
	
	sprite.modulate = Color(1, 0, 0)
	sprite.scale = Vector2(1.2, 1.2)
	
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.4)
	tween.parallel().tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.4)
	
	if hit_sound_player:
		hit_sound_player.play()

func _on_area_2d_body_entered(body: Node2D) -> void:
	play_hit_animation()
	hit.emit()

func _on_area_2d_area_entered(area: Area2D) -> void:
	play_hit_animation()
	hit.emit()
