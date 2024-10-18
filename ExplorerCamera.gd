extends Camera2D



const DRAG_STOP_DISTANCE = 10
const DRAG_SPEED = 15



var stored_global_position = Vector2()
var stored_global_mouse_position = Vector2()
var previous_mouse_position = Vector2(0, 0)

#var new_velocity = Vector2()

@export var move_speed = 100



func _process(delta):
	stored_global_position = global_position
	stored_global_mouse_position = get_global_mouse_position()
	if MapGlobal.can_move_camera:
		check_for_drag(delta)
		check_for_movement(delta)



func check_for_movement(delta):
	var deltad_speed = move_speed * delta
	if Input.is_anything_pressed():
		if Input.is_action_pressed("move_up"):
			if not global_position.y - deltad_speed < MapGlobal.screen_size.y / 2:
				global_position.y -= deltad_speed
				check_for_map_edges()
		if Input.is_action_pressed("move_down"):
			if not global_position.y + deltad_speed > MapGlobal.MAP_HEIGHT - (MapGlobal.screen_size.y / 2):
				global_position.y += deltad_speed
				check_for_map_edges()
		if Input.is_action_pressed("move_left"):
			global_position.x -= deltad_speed
			check_for_map_edges()
		if Input.is_action_pressed("move_right"):
			global_position.x += deltad_speed
			check_for_map_edges()



func check_for_map_edges():
	if global_position.x > MapGlobal.MAP_WIDTH + 1:
		global_position.x -= MapGlobal.MAP_WIDTH
	if global_position.x < -1:
		global_position.x += MapGlobal.MAP_WIDTH
	if global_position.y > MapGlobal.MAP_HEIGHT - (MapGlobal.screen_size.y / 2) + 1:
		global_position.y = MapGlobal.MAP_HEIGHT - (MapGlobal.screen_size.y / 2)
	if global_position.y < (MapGlobal.screen_size.y / 2) - 1:
		global_position.y = (MapGlobal.screen_size.y / 2)



func check_for_drag(delta):
	if Input.is_action_pressed("left_click"):
		if MapGlobal.can_move_camera:
			if not previous_mouse_position == Vector2(0, 0):
				var mouse_local_to_screen = get_global_mouse_position() - global_position
				var new_velocity = mouse_local_to_screen - previous_mouse_position
				global_position -= new_velocity
				previous_mouse_position = mouse_local_to_screen
				check_for_map_edges()
			else:
				previous_mouse_position = get_global_mouse_position() - global_position
	if Input.is_action_just_released("left_click"):
		previous_mouse_position = Vector2(0, 0)
