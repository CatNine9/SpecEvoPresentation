extends Control



func _input(event):
	if event.is_action_pressed("escape_menu"):
		print("Escape pressed")
		resume_exploring.call_deferred()



func resume_exploring():
	visible = false
	get_tree().paused = false
