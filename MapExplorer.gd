extends Node2D

const BUTTON_PLACE_OFFSET = 25
const MIN_ZONE_BUTTONS = 2
const ZONE_BUTTON_Y = 35

var previous_mouse_position = Vector2(0, 0)

var is_just_starting = true

@onready var explorer_camera = $ExplorerCamera

@onready var invisible_cursor = $InvisibleCursor

@onready var map_image = $MapControl/MapImage
@onready var map_extension_1 = $MapExtension
@onready var map_extension_2 = $MapExtension2

@onready var locations_of_interest = $LOIs

@onready var escape_menu_control = $CanvasLayer/EscapeMenuControl

@onready var timeline_control = $CanvasLayer/TimelineControl
@onready var current_year_label = $CanvasLayer/TimelineControl/MarginContainer/HBoxContainer/CurrentYearLabel
@onready var north_season_control = $CanvasLayer/NorthSeasonControl

@onready var clickdrag_window_control = $CanvasLayer/ClickdragWindowControl
@onready var clickdrag_title_label = $CanvasLayer/ClickdragWindowControl/MarginContainer/PanelContainer/VBoxContainer/WindowNameContainer/WindowNameTitle
@onready var clickdrag_image = $CanvasLayer/ClickdragWindowControl/MarginContainer/PanelContainer/VBoxContainer/WindowImageContainer/ScrollContainer/ClickdragImageRect

@onready var zone_picker_control = $ZonePickerControl
@onready var zone_button_container = $ZonePickerControl/PanelContainer/VBoxContainer/PanelContainer2/ZoneButtonContainer

@onready var zones = $Zones
@onready var ranges_layer = $Ranges
@onready var land_ranges = $Ranges/LandBasePolygons

@onready var species_list_control = $CanvasLayer/SpeciesListControl
@onready var species_list_scroll_container_vbox = $CanvasLayer/SpeciesListControl/PanelContainer/VBoxContainer/MarginContainer2/PanelContainer/MarginContainer/SpeciesListScrollContainer/VBoxContainer

@onready var species_window = $CanvasLayer/SpeciesViewControl
@onready var ancestor_button = $CanvasLayer/SpeciesViewControl/MarginContainer/SpeciesViewContainer/VBoxContainer/TitleContainer/HBoxContainer/AncestorButton
@onready var ancestor_link_button = $CanvasLayer/SpeciesViewControl/MarginContainer/SpeciesViewContainer/VBoxContainer/TitleContainer/HBoxContainer/AncestorButton2
@onready var ancestor_link_label = $CanvasLayer/SpeciesViewControl/MarginContainer/SpeciesViewContainer/VBoxContainer/TitleContainer/HBoxContainer/AncestorButton2/AncestorLabel
@onready var ancestor_label = $CanvasLayer/SpeciesViewControl/MarginContainer/SpeciesViewContainer/VBoxContainer/TitleContainer/HBoxContainer/AncestorButton
@onready var species_title_label = $CanvasLayer/SpeciesViewControl/MarginContainer/SpeciesViewContainer/VBoxContainer/TitleContainer/HBoxContainer/SpeciesTitleLabel
@onready var descendant_selector = $CanvasLayer/SpeciesViewControl/MarginContainer/SpeciesViewContainer/VBoxContainer/TitleContainer/HBoxContainer/DescendantSelector
@onready var species_image = $CanvasLayer/SpeciesViewControl/MarginContainer/SpeciesViewContainer/VBoxContainer/ContentContainer/ScrollContainer/VBoxContainer/HBoxContainer/SpeciesImage
@onready var timespan_field = $CanvasLayer/SpeciesViewControl/MarginContainer/SpeciesViewContainer/VBoxContainer/ContentContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer/InfoBlock3/HBoxContainer/TimespanField
@onready var range_habitat_field = $CanvasLayer/SpeciesViewControl/MarginContainer/SpeciesViewContainer/VBoxContainer/ContentContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer/InfoBlock2/HBoxContainer/RangeHabitatField
@onready var ecology_field = $CanvasLayer/SpeciesViewControl/MarginContainer/SpeciesViewContainer/VBoxContainer/ContentContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer/InfoBlock5/HBoxContainer/EcologyField
@onready var description_field = $CanvasLayer/SpeciesViewControl/MarginContainer/SpeciesViewContainer/VBoxContainer/ContentContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer/InfoBlock4/HBoxContainer/DescriptionField

################################################################################



func _ready():
	GlobalSignals.connect("opening_species_window", open_species_window)
	GlobalSignals.connect("inspecting_zones", inspect_hovered_zones)
	GlobalSignals.connect("opening_clickdrag_window", open_clickdrag_window)
	refresh_map()
	resume_exploring()
	is_just_starting = false



################################################################################
#region Controls:
# Input function and functions directly related to input:



func _input(event):
	if Input.is_action_just_pressed("left_click"):
		if clickdrag_window_control.visible:
			match_last_mouse_position_to(clickdrag_window_control.get_global_mouse_position())
		else:
			match_last_mouse_position_to(get_global_mouse_position())
		if MapGlobal.is_clickdrag_focused:
			previous_mouse_position = get_global_mouse_position() - global_position

	if Input.is_action_pressed("left_click"):
		if MapGlobal.is_viewing_species:
			return
			# Do whatever it is left click inputs do here, not sure yet.
			# This is really just to prevent left click drag and select in other
			# windows if is_viewing_species == true.
			# Using return ends things before the rest of the function happens.
		else:
			if MapGlobal.is_clickdrag_focused:
				drag_scroll_image(clickdrag_image, previous_mouse_position)

	if event.is_action_pressed("right_click"):
		if not MapGlobal.is_ui_focused:
			open_inhabitants_list()
	
	if event.is_action_pressed("escape_menu"):
		if not escape_menu_control.visible and not MapGlobal.is_ui_focused:
			pause_exploring()



func drag_scroll_image(image, scroll_positions):
	var h_scroll = image.get_parent().get_child(1, true)
	var v_scroll = image.get_parent().get_child(2, true)
	var mouse_local_to_screen = get_global_mouse_position() - global_position
	var new_velocity = mouse_local_to_screen - previous_mouse_position
	h_scroll.value -= new_velocity.x
	v_scroll.value -= new_velocity.y
	previous_mouse_position = mouse_local_to_screen



func match_last_mouse_position_to(pos_to_match_to):
	MapGlobal.last_mouse_click_position = pos_to_match_to
#endregion

################################################################################
#region General Utility
# Misc reusable functions:



func wait(seconds):
	await get_tree().create_timer(seconds,true,true,false).timeout



func pause_exploring():
	get_tree().paused = true
	escape_menu_control.visible = true



func resume_exploring():
	get_tree().paused = false
	escape_menu_control.visible = false



func refresh_map():
	load_current_map()
	load_land_polygons()
	load_zones()
	load_buttons()
	load_species_areas()



func quit_app():
	get_tree().quit()



func quit_map_to_main():
	queue_free()
#endregion

################################################################################
#region UI Utility:



func open_clickdrag_window(window_zone):
	clickdrag_window_control.visible = true
	MapGlobal.is_clickdrag_focused = true
	if clickdrag_window_control.visible == false:
		clear_map_zones()
	else:
		clear_window_zones()
	wipe_clickdrag_image_contents()
	setup_window_scrollbars(clickdrag_image)
	map_is_covered(true)
	populate_clickdrag_window(window_zone)

func clear_map_zones():
	MapGlobal.zones_hovering = []
	for zone in zones.get_children():
		zone.is_hovered = false

func clear_window_zones():
	for this_node in clickdrag_image.get_children():
		this_node.queue_free()

func wipe_clickdrag_image_contents():
	for this_node in clickdrag_image.get_children():
		this_node.queue_free()

func setup_window_scrollbars(window_image):
	var h_scroll = window_image.get_parent().get_child(1, true)
	var v_scroll = window_image.get_parent().get_child(2, true)
	h_scroll.mouse_filter = 2
	v_scroll.mouse_filter = 2

func map_is_covered(condition):
	if condition:
		condition = false
	else:
		condition = true
	timeline_control.visible = condition
	north_season_control.visible = condition
	MapGlobal.can_move_camera = condition

func populate_clickdrag_window(window_zone):
	var zone_data = ZonesData.load_zone(window_zone.zone_name)
	clickdrag_title_label.text = window_zone.zone_name
	clickdrag_image.texture = zone_data.zone_image
	for this_zone in zone_data.zones_in_this_zone:
		var zone_within_data = ZonesData.load_zone(this_zone)
		var new_polygon = preload("res://UI/Map/ZoneTemplate.tscn").instantiate()
		clickdrag_image.add_child(new_polygon)
		new_polygon.zone_shape_polygon.polygon = zone_within_data.zone_shape_polygon.polygon
		new_polygon.zone_shape_fill.polygon =  zone_within_data.zone_shape_polygon.polygon
		new_polygon.zone_shape_line.points = zone_within_data.zone_shape_polygon.polygon
		new_polygon.zone_name = zone_within_data.zone_name
		new_polygon.zone_sprite.visible = true 
		new_polygon.zone_sprite.texture = zone_within_data.zone_sprite
		new_polygon.zone_sprite.position = zone_within_data.zone_sprite_position



func close_clickdrag_window():
	clickdrag_window_control.visible = false
	MapGlobal.can_move_camera = true
	MapGlobal.zones_hovering = []
	map_is_covered(false)



func open_inhabitants_list():
	if species_list_control.visible:
		for this_button in species_list_scroll_container_vbox.get_children():
			this_button.queue_free()
		species_list_control.visible = false
		MapGlobal.species_ranges_hovering.clear()
	else:
		species_list_control.visible = true
		for this_species in MapGlobal.species_ranges_hovering:
			var new_species_button = preload("res://UI/Buttons/TemplateListedSpecies.tscn").instantiate()
			species_list_scroll_container_vbox.add_child(new_species_button)
			new_species_button.species_name_label.text = this_species



func open_species_window(species_name):
	MapGlobal.current_selected_species = species_name
	species_window.visible = true
	MapGlobal.is_viewing_species = true
	var species_data = SpeciesData.load_species(species_name)
	if species_data.ancestor_link != null:
		ancestor_button.visible = false
		ancestor_link_button.visible = true
		ancestor_link_button.uri = species_data.ancestor_link
		ancestor_link_label.text = species_data.species_ancestor
	else:
		ancestor_button.visible = true
		ancestor_link_button.visible = false
		ancestor_label.text = species_data.species_ancestor
	ancestor_label.text = species_data.species_ancestor
	species_title_label.text = species_data.species_name
	descendant_selector # Populate this later
	if species_data.species_timespan.size() == 1:
		timespan_field.text = str(species_data.species_timespan[0]) + "Yh"
	else:
		timespan_field.text = "From: " + str(species_data.species_timespan[0]) + "Yh, To: " + str(species_data.species_timespan[species_data.species_timespan.size() - 1]) + "Yh"
	range_habitat_field.text = species_data.species_range_and_habitat
	ecology_field.text = species_data.species_ecology
	description_field.text = species_data.species_description
	species_image.texture = species_data.species_illustration



func close_species_window():
	species_window.visible = false
	MapGlobal.is_viewing_species = false



func inspect_hovered_zones():
	if MapGlobal.zones_hovering.size() >= MIN_ZONE_BUTTONS: # If the zone choose window needs to be opened...
		open_zone_picker()
		if MapGlobal.zones_hovering.size() > MIN_ZONE_BUTTONS: # If more space for buttons is needed...
			var extra_space = (MapGlobal.zones_hovering.size() - MIN_ZONE_BUTTONS) * ZONE_BUTTON_Y
			zone_picker_control.size.y += extra_space
		for this_zone in MapGlobal.zones_hovering:
			var new_button = preload("res://UI/Windows/template_zone_button.tscn").instantiate()
			zone_button_container.add_child(new_button)
			zone_button_container.label.text = this_zone.zone_name
		# To actually test all this, make another overlapping zone.
	else: # If the zone picker isn't needed...
		open_clickdrag_window(MapGlobal.zones_hovering[0])
	MapGlobal.zones_hovering.clear()

func open_zone_picker():
	zone_picker_control.visible = true
	zone_picker_control.global_position = get_global_mouse_position()



func change_to_previous_timestop():
	var all_maps = MapData.get_children()
	var lowest_map_id = all_maps[0].map_id
	if MapGlobal.current_map_id > lowest_map_id:
		MapGlobal.current_map_id -= 1
	refresh_map()

func change_to_next_timestop():
	var all_maps = MapData.get_children()
	var highest_map_id = all_maps[all_maps.size() - 1].map_id
	if MapGlobal.current_map_id < highest_map_id:
		MapGlobal.current_map_id += 1
	refresh_map()



func change_to_n_summer():
	if MapGlobal.current_north_season == "Winter":
		MapGlobal.current_north_season = "Summer"
		var map_script = MapData.load_map_data(MapGlobal.current_map_id)
		map_image.texture = map_script.map_sprite_sw
		map_extension_1.texture = map_script.map_sprite_sw
		map_extension_2.texture = map_script.map_sprite_sw

func change_to_n_winter():
	if MapGlobal.current_north_season == "Winter":
		MapGlobal.current_north_season = "Summer"
		var map_script = MapData.load_map_data(MapGlobal.current_map_id)
		map_image.texture = map_script.map_sprite_sw
		map_extension_1.texture = map_script.map_sprite_sw
		map_extension_2.texture = map_script.map_sprite_sw
#endregion

################################################################################
#region Called from ready:
# Functions that are called when the map explorer scene is loaded:



func load_current_map():
	MapGlobal.current_map = MapData.load_map_data(MapGlobal.current_map_id)
	MapGlobal.current_map_start_position = MapGlobal.current_map.map_start_position
	if MapGlobal.current_north_season == "Winter":
		map_image.texture = MapGlobal.current_map.map_sprite_nw
	else:
		map_image.texture = MapGlobal.current_map.map_sprite_sw
	MapGlobal.current_year = MapGlobal.current_map.map_year
	current_year_label.text = "Year: " + str(MapGlobal.current_year)
	explorer_camera.global_position = MapGlobal.current_map_start_position
	map_extension_1.texture = map_image.texture
	map_extension_2.texture = map_image.texture



func load_land_polygons():
	if not is_just_starting:
		for this_land in land_ranges.get_children():
			this_land.queue_free()
	if MapGlobal.current_map.shape.get_children().size() > 0:
		for this_polygon in MapGlobal.current_map.shape.get_children():
			var new_polygon = Polygon2D.new()
			new_polygon.polygon = this_polygon.polygon
			new_polygon.modulate = Color(1.0, 1.0, 1.0, 0.0)
			land_ranges.add_child(new_polygon)



# If not start of game, clear current loaded zones first.
func load_zones():
	if not is_just_starting:
		for this_zone in zones.get_children():
			this_zone.queue_free()
	for this_zone in MapGlobal.current_map.map_zones:
		var new_zone = preload("res://UI/Map/ZoneTemplate.tscn").instantiate()
		var zone_ref = ZonesData.load_zone(this_zone)
		zones.add_child(new_zone)
		new_zone.zone_name = zone_ref.zone_name
		new_zone.zone_shape_line.default_color = Color(0.50, 0.80, 0.80, 0.25)
		new_zone.zone_shape_fill.color = Color(0.50, 0.80, 0.80, 0.10)
		new_zone.zone_shape_polygon.polygon = zone_ref.zone_shape_polygon.polygon
		new_zone.zone_shape_line.points = new_zone.zone_shape_polygon.polygon
		new_zone.zone_shape_fill.polygon = new_zone.zone_shape_polygon.polygon



# If not start of game, clear current loaded buttons first.
func load_buttons():
	if not is_just_starting:
		for this_loi in locations_of_interest.get_children():
			this_loi.queue_free()
	for this_location in MapGlobal.current_map.map_lois:
		var new_button = preload("res://UI/Map/LOIButton.tscn").instantiate()
		var location_script = LocationsOfInterestData.load_location_of_interest(this_location[1])
		locations_of_interest.add_child(new_button)
		new_button.global_position = this_location[0]
		new_button.global_position.x -= BUTTON_PLACE_OFFSET
		new_button.global_position.y -= BUTTON_PLACE_OFFSET
		new_button.loi_name = this_location[1]
		new_button.icon_sprite.texture = location_script.loi_icon



func load_species_areas():
	if not is_just_starting:
		for this_range in ranges_layer.get_children():
			if this_range.get_class() == "Area2D":
				this_range.queue_free()
	for this_species in SpeciesData.get_children():
		if MapGlobal.current_year <= this_species.species_timespan[this_species.species_timespan.size() - 1] and MapGlobal.current_year >= this_species.species_timespan[0]:
			var range_count = 0
			for this_range in this_species.population_ranges.get_children():
				var new_range_area = preload("res://UI/Map/RangeAreaTemplate.tscn").instantiate()
				ranges_layer.add_child(new_range_area)
				new_range_area.range_shape.polygon = this_range.polygon
				new_range_area.range_species = this_species.species_name
				new_range_area.range_index = range_count
				range_count += 1
#endregion

################################################################################
#region Area signals:
# Functions that run when the mouse hovers over certain polygon shapes:



func _on_zone_view_container_mouse_entered():
	MapGlobal.is_ui_focused = true



func _on_zone_view_container_mouse_exited():
	MapGlobal.is_ui_focused = false



func _on_clickdrag_image_rect_mouse_entered():
	MapGlobal.is_clickdrag_focused = true



func _on_clickdrag_image_rect_mouse_exited():
	MapGlobal.is_clickdrag_focused = false



func _on_species_view_container_mouse_entered():
	pass # Replace with function body.



func _on_species_view_container_mouse_exited():
	pass # Replace with function body.
#endregion

################################################################################
#region Called from button signals
# For when certain buttons are pressed.



func _on_close_species_view_button_button_up():
	close_species_window()



func _on_ancestor_button_2_button_up():
	open_species_window(MapGlobal.current_selected_species) # The species window is already open, but it shouldn't matter because it just sets it to visible doesn't create a new one. This populates the window too.



func _on_previous_time_button_button_up():
	change_to_previous_timestop()

func _on_next_time_button_button_up():
	change_to_next_timestop()



func _on_summer_button_button_up():
	change_to_n_summer()

func _on_winter_button_button_up():
	change_to_n_winter()



func _on_quit_button_button_up():
	quit_app()



func _on_return_button_button_up():
	quit_map_to_main()



func _on_resume_button_button_up():
	resume_exploring()



func _on_close_clickdrag_view_button_button_up():
	close_clickdrag_window()
#endregion
