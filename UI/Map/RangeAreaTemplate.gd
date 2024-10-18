extends Area2D



var range_species = ""
var range_index = 0



var is_hovering = false



@onready var range_shape = $RangeShape



func _input(event):
	if event.is_action_pressed("right_click") and is_hovering:
		print("Range right click")
		MapGlobal.species_ranges_hovering.append(range_species)
		print(MapGlobal.species_ranges_hovering)



func _on_mouse_entered():
	is_hovering = true


func _on_mouse_exited():
	is_hovering = false
