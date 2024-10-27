extends Control





func _on_new_button_button_up():
	var new_scene = preload("res://MapExplorer.tscn").instantiate()
	add_child(new_scene)



func _on_quit_button_button_up():
	get_tree().quit()
