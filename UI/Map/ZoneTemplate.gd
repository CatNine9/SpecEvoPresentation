extends Area2D



var zone_name = ""

var is_hovered = false
var is_animating_reverse = false



@onready var zone_shape_polygon = $ZoneShapePolygon
@onready var zone_shape_line = $ZoneShapeLine
@onready var zone_shape_fill = $ZoneShapeFill
@onready var zone_sprite = $ZoneSprite
@onready var animation_cycle_time = $AnimationCycleTime
@onready var frame_change_time = $FrameChangeTime



func _ready():
	animation_cycle_time.start()



func _input(event):
	if is_hovered == true: # and MapGlobal.is_loi_focused == false and MapGlobal.is_ui_focused == false and MapGlobal.is_viewing_species == false:
		if event.is_action_released("left_click"):
			#if MapGlobal.last_mouse_click_position.x < get_global_mouse_position().x + 10 and MapGlobal.last_mouse_click_position.x > get_global_mouse_position().x - 10:
				#if MapGlobal.last_mouse_click_position.y < get_global_mouse_position().y + 10 and MapGlobal.last_mouse_click_position.y > get_global_mouse_position().y - 10:
			GlobalSignals.inspect_zones()



func _physics_process(delta):
	if is_hovered:
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_POINTING_HAND)



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
	


func _on_animation_cycle_time_timeout():
	do_animation_cycle()




func do_animation_cycle():
	if not is_animating_reverse:
		zone_sprite.frame += 1
		if zone_sprite.frame < zone_sprite.hframes - 1:
			frame_change_time.start()
		elif zone_sprite.frame == zone_sprite.hframes - 1:
			is_animating_reverse = true
			frame_change_time.start()
	else:
		zone_sprite.frame -= 1
		if zone_sprite.frame > 0:
			frame_change_time.start()
		elif zone_sprite.frame == 0:
			is_animating_reverse = false
			animation_cycle_time.start()


func _on_frame_change_time_timeout():
	do_animation_cycle()
