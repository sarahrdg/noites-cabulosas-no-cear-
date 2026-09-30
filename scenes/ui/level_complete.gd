extends Control

func _on_btn_next_level_button_up() -> void:
	get_tree().change_scene_to_file("res://scenes/world_2.tscn")

func _on_btn_back_menu_button_up() -> void:
	get_tree().change_scene_to_file("res://ui_start.tscn")
