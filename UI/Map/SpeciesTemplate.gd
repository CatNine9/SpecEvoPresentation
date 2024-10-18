extends Area2D



var species_name = ""

var is_hovered = false
var is_animating_reverse = false


@onready var species_shape_polygon = $SpeciesShapePolygon
@onready var species_shape_line = $SpeciesShapeLine
@onready var species_shape_fill = $SpeciesShapeFill
@onready var species_sprite = $SpeciesSprite
@onready var animation_cycle_time = $AnimationCycleTime
@onready var frame_change_time = $FrameChangeTime



func _ready():
	animation_cycle_time.start()



func _physics_process(delta):
	if is_hovered:
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_POINTING_HAND)



func _input(event):
	if is_hovered:
		if event.is_action_released("left_click"):
			if MapGlobal.last_mouse_click_position.x < get_global_mouse_position().x + 10 and MapGlobal.last_mouse_click_position.x > get_global_mouse_position().x - 10:
				if MapGlobal.last_mouse_click_position.y < get_global_mouse_position().y + 10 and MapGlobal.last_mouse_click_position.y > get_global_mouse_position().y - 10:
					GlobalSignals.open_species_window(species_name)



func _on_mouse_entered():
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_POINTING_HAND)
	MapGlobal.location_in_zones_hovering = self
	is_hovered = true



func _on_mouse_exited():
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
	MapGlobal.location_in_zones_hovering = null
	is_hovered = false



#func _on_animation_cycle_time_timeout():
	#do_animation_cycle()




#func do_animation_cycle():
	#if not is_animating_reverse:
		#loi_sprite.frame += 1
		#if loi_sprite.frame < loi_sprite.hframes - 1:
			#frame_change_time.start()
		#elif loi_sprite.frame == loi_sprite.hframes - 1:
			#is_animating_reverse = true
			#frame_change_time.start()
	#else:
		#loi_sprite.frame -= 1
		#if loi_sprite.frame > 0:
			#frame_change_time.start()
		#elif loi_sprite.frame == 0:
			#is_animating_reverse = false
			#animation_cycle_time.start()



#func _on_frame_change_time_timeout():
	#do_animation_cycle()
