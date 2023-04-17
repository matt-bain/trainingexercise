extends Node2D

func _on_title_screen_button_pressed():
	var titles = get_node("Title Screen")
	remove_child(titles)
	titles.call_deferred("free")
	
	get_tree().change_scene_to_file("res://Task1.tscn")
