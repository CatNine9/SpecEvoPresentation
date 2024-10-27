extends Button



var loi_name = ""


@onready var icon_sprite = $LOIICon


func _on_button_up():
	pass
	#if not MapGlobal.is_viewing_species:
		#GlobalSignals.open_loi_window(loi_name)
		#



func _on_mouse_entered():
	MapGlobal.is_loi_focused = true



func _on_mouse_exited():
	MapGlobal.is_loi_focused = false
