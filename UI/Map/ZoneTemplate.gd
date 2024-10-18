extends Area2D



var zone_name = ""

var is_hovered = false


@onready var zone_shape_polygon = $ZoneShapePolygon
@onready var zone_shape_line = $ZoneShapeLine
@onready var zone_shape_fill = $ZoneShapeFill



func _input(event):
	if is_hovered == true and MapGlobal.is_loi_focused == false and MapGlobal.is_ui_focused == false and MapGlobal.is_viewing_species == false:
		if event.is_action_released("left_click"):
			if MapGlobal.last_mouse_click_position.x < get_global_mouse_position().x + 10 and MapGlobal.last_mouse_click_position.x > get_global_mouse_position().x - 10:
				if MapGlobal.last_mouse_click_position.y < get_global_mouse_position().y + 10 and MapGlobal.last_mouse_click_position.y > get_global_mouse_position().y - 10:
					GlobalSignals.inspect_zones()



func _on_mouse_entered():
	MapGlobal.zones_hovering.append(self)
	is_hovered = true
	zone_shape_line.default_color = Color(0.50, 0.80, 0.80, 0.5)
	zone_shape_fill.color = Color(0.50, 0.80, 0.80, 0.25)


func _on_mouse_exited():
	MapGlobal.zones_hovering.erase(self)
	is_hovered = false
	zone_shape_line.default_color = Color(0.50, 0.80, 0.80, 0.25)
	zone_shape_fill.color = Color(0.50, 0.80, 0.80, 0.1)
	
