extends Node



const MAP_HEIGHT = 2000
const MAP_WIDTH = 4000



var screen_size = Vector2(1920, 1010)

var can_move_camera = true


var current_year = 0
var current_map_id = 0
var current_north_season = "Winter"
var current_map = null
var current_selected_loi = null
var current_map_start_position = Vector2()

var current_selected_species = ""



var zones_hovering = []
var navigation_history = []
var nav_history_index = -1
var location_in_zones_hovering = null
var is_clickdrag_focused = false
var is_ui_focused = false
var is_viewing_species = false

var species_ranges_hovering = []

var last_mouse_click_position = Vector2()
