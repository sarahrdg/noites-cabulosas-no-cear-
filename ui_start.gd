extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_btn_exit_button_up() -> void:
	get_tree().quit()
