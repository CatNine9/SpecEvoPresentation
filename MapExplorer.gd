extends Node2D

const BUTTON_PLACE_OFFSET = 25
const MIN_ZONE_BUTTONS = 2
const ZONE_BUTTON_Y = 35

var previous_zone_scroll_positions = Vector2(0, 0)
var previous_loi_scroll_positions = Vector2(0, 0)
var previous_mouse_position = Vector2(0, 0)

@onready var explorer_camera = $ExplorerCamera

@onready var invisible_cursor = $InvisibleCursor

@onready var map_image = $MapControl/MapImage
@onready var map_extension_1 = $MapExtension
@onready var map_extension_2 = $MapExtension2

@onready var locations_of_interest = $LOIs

@onready var timeline_control = $CanvasLayer/TimelineControl
@onready var current_year_label = $CanvasLayer/TimelineControl/MarginContainer/HBoxContainer/CurrentYearLabel

@onready var zones = $Zones
@onready var zone_picker_control = $ZonePickerControl
@onready var zone_button_container = $ZonePickerControl/PanelContainer/VBoxContainer/PanelContainer2/ZoneButtonContainer

@onready var loi_window = $CanvasLayer/LocationViewControl
@onready var loi_title = $CanvasLayer/LocationViewControl/MarginContainer/PanelContainer/VBoxContainer/LocationNameContainer/LocationNameTitle
@onready var loi_image = $CanvasLayer/LocationViewControl/MarginContainer/PanelContainer/VBoxContainer/LocationImageContainer/ScrollContainer/LocationImageRect

@onready var ranges_layer = $Ranges
@onready var land_ranges = $Ranges/LandBasePolygons

@onready var zone_window = $CanvasLayer/ZoneViewControl
@onready var zone_container = $CanvasLayer/ZoneViewControl/MarginContainer/ZoneViewContainer
@onready var zone_title = $CanvasLayer/ZoneViewControl/MarginContainer/ZoneViewContainer/VBoxContainer/TitleContainer/ZoneTitleLabel
@onready var zone_image = $CanvasLayer/ZoneViewControl/MarginContainer/ZoneViewContainer/VBoxContainer/ContentContainer/ScrollContainer/ZoneImageRect

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
	GlobalSignals.connect("opening_loi_window", open_loi_window)
	GlobalSignals.connect("opening_species_window", open_species_window)
	GlobalSignals.connect("inspecting_zones", inspect_hovered_zones)
	load_current_map()
	load_land_polygons()
	load_zones()
	load_buttons()
	load_species_areas()



################################################################################
#region Controls:

func _input(event):
	if Input.is_action_just_pressed("left_click"):
		if zone_window.visible:
			MapGlobal.last_mouse_click_position = zone_container.get_global_mouse_position()
		elif loi_window.visible:
			MapGlobal.last_mouse_click_position = loi_window.get_global_mouse_position()
		else:
			MapGlobal.last_mouse_click_position = get_global_mouse_position()
		if MapGlobal.is_zone_image_focused:
			previous_mouse_position = get_global_mouse_position() - global_position
		if MapGlobal.is_loi_image_focused:
			previous_mouse_position = get_global_mouse_position() - global_position
	if Input.is_action_pressed("left_click"):
		if MapGlobal.is_viewing_species:
			return
			# Do whatever it is left click inputs do here, not sure yet.
			# This is really just to prevent left click drag and select in other windows if is_viewing_species == true.
			# Using return ends things before the rest of the function happens.
		else:
			if MapGlobal.is_zone_image_focused:
				drag_scroll_image(zone_image, previous_zone_scroll_positions)
			if MapGlobal.is_loi_image_focused:
				drag_scroll_image(loi_image, previous_loi_scroll_positions)
	if event.is_action_pressed("right_click"):
		if not MapGlobal.is_ui_focused:
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



func wait(seconds):
	await get_tree().create_timer(seconds,true,true,false).timeout



func drag_scroll_image(image, scroll_positions):
	var h_scroll = image.get_parent().get_child(1, true)
	var v_scroll = image.get_parent().get_child(2, true)
	var mouse_local_to_screen = get_global_mouse_position() - global_position
	var new_velocity = mouse_local_to_screen - previous_mouse_position
	h_scroll.value -= new_velocity.x
	v_scroll.value -= new_velocity.y
	previous_mouse_position = mouse_local_to_screen
#endregion

################################################################################
#region Called from ready:

func load_current_map():
	MapGlobal.current_map = MapData.load_map_data(MapGlobal.current_map_id)
	MapGlobal.current_map_start_position = MapGlobal.current_map.map_start_position
	map_image.texture = MapGlobal.current_map.map_sprite_nw
	MapGlobal.current_year = MapGlobal.current_map.map_year
	current_year_label.text = "Year: " + str(MapGlobal.current_year)
	explorer_camera.global_position = MapGlobal.current_map_start_position
	map_extension_1.texture = map_image.texture
	map_extension_2.texture = map_image.texture



func load_land_polygons():
	print(MapGlobal.current_map.shape.get_children())
	for this_polygon in MapGlobal.current_map.shape.get_children():
		var new_polygon = Polygon2D.new()
		new_polygon.polygon = this_polygon.polygon
		new_polygon.modulate = Color(1.0, 1.0, 1.0, 0.0)
		land_ranges.add_child(new_polygon)



# If not start of game, clear current loaded zones first.
func load_zones():
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

func _on_zone_view_container_mouse_entered():
	MapGlobal.is_ui_focused = true



func _on_zone_view_container_mouse_exited():
	MapGlobal.is_ui_focused = false



func _on_zone_image_rect_mouse_entered():
	MapGlobal.is_zone_image_focused = true



func _on_zone_image_rect_mouse_exited():
	MapGlobal.is_zone_image_focused = false



func _on_location_image_rect_mouse_entered():
	MapGlobal.is_loi_image_focused = true



func _on_location_image_rect_mouse_exited():
	MapGlobal.is_loi_image_focused = false



func _on_species_view_container_mouse_entered():
	pass # Replace with function body.



func _on_species_view_container_mouse_exited():
	pass # Replace with function body.
#endregion

################################################################################
# Called from GlobalSignals:



func open_loi_window(this_loi_name):
	for this_node in loi_image.get_children():
		this_node.queue_free()
	var h_scroll = zone_image.get_parent().get_child(1, true)
	var v_scroll = zone_image.get_parent().get_child(2, true)
	h_scroll.mouse_filter = 2
	v_scroll.mouse_filter = 2
	zone_window.visible = false
	timeline_control.visible = false
	MapGlobal.can_move_camera = false
	MapGlobal.is_loi_focused = false
	loi_window.visible = true
	var this_loi = LocationsOfInterestData.load_location_of_interest(this_loi_name)
	loi_title.text = this_loi_name
	loi_image.texture = this_loi.loi_image
	for this_location in this_loi.loi_locations:
		var loi_data = LocationsOfInterestData.load_location_of_interest(this_location)
		var new_polygon = preload("res://UI/Map/LOITemplate.tscn").instantiate()
		loi_image.add_child(new_polygon)
		new_polygon.loi_shape_polygon.polygon = loi_data.location_shape_polygon.polygon
		new_polygon.loi_shape_fill.polygon = loi_data.location_shape_polygon.polygon
		new_polygon.loi_shape_line.points = loi_data.location_shape_polygon.polygon
		new_polygon.loi_name = loi_data.loi_name
		new_polygon.loi_sprite.visible = true 
		new_polygon.loi_sprite.texture = loi_data.loi_zone_view_sprite
		new_polygon.loi_sprite.position = loi_data.loi_zone_view_sprite_position
	if this_loi.loi_species.size() > 0:
		for this_species in this_loi.loi_species:
			var species_data = SpeciesData.load_species(this_species[0])
			for this_polygon in this_species:
				if typeof(this_polygon) == 24:
					var new_polygon = preload("res://UI/Map/SpeciesTemplate.tscn").instantiate()
					loi_image.add_child(new_polygon)
					new_polygon.species_shape_polygon.polygon = this_species[1].polygon
					new_polygon.species_shape_fill.polygon = this_species[1].polygon
					new_polygon.species_shape_line.points = this_species[1].polygon
					new_polygon.species_name = species_data.species_name
	clear_hovered_zones()



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


func inspect_hovered_zones():
	if MapGlobal.zones_hovering.size() >= MIN_ZONE_BUTTONS: # If the zone choose window needs to be opened...
		summon_zone_picker()
		if MapGlobal.zones_hovering.size() > MIN_ZONE_BUTTONS: # If more space for buttons is needed...
			var extra_space = (MapGlobal.zones_hovering.size() - MIN_ZONE_BUTTONS) * ZONE_BUTTON_Y
			zone_picker_control.size.y += extra_space
		for this_zone in MapGlobal.zones_hovering:
			var new_button = preload("res://UI/Windows/template_zone_button.tscn").instantiate()
			zone_button_container.add_child(new_button)
			zone_button_container.label.text = this_zone.zone_name
		# To actually test all this, make another overlapping zone.
	else: # If the zone picker isn't needed...
		open_zone_window()



func open_zone_window():
	for this_node in loi_image.get_children():
		this_node.queue_free()
	var h_scroll = zone_image.get_parent().get_child(1, true)
	var v_scroll = zone_image.get_parent().get_child(2, true)
	h_scroll.mouse_filter = 2
	v_scroll.mouse_filter = 2
	timeline_control.visible = false
	zone_window.visible = true
	MapGlobal.can_move_camera = false
	MapGlobal.is_loi_focused = false
	var this_zone = ZonesData.load_zone(MapGlobal.zones_hovering[0].zone_name)
	zone_title.text = this_zone.zone_name
	zone_image.texture = this_zone.zone_image
	for this_location in this_zone.zone_locations:
		var loi_data = LocationsOfInterestData.load_location_of_interest(this_location)
		var new_polygon = preload("res://UI/Map/LOITemplate.tscn").instantiate()
		zone_image.add_child(new_polygon)
		new_polygon.loi_shape_polygon.polygon = loi_data.location_shape_polygon.polygon
		new_polygon.loi_shape_fill.polygon = loi_data.location_shape_polygon.polygon
		new_polygon.loi_shape_line.points = loi_data.location_shape_polygon.polygon
		new_polygon.loi_name = loi_data.loi_name
		new_polygon.loi_sprite.visible = true 
		new_polygon.loi_sprite.texture = loi_data.loi_zone_view_sprite
		new_polygon.loi_sprite.position = loi_data.loi_zone_view_sprite_position
	clear_hovered_zones()



################################################################################
# Called from buttons:



func _on_close_location_view_button_button_up():
	close_loi_window()



func _on_close_zone_view_button_button_up():
	close_zone_window()



func _on_close_species_view_button_button_up():
	close_species_window()



func _on_ancestor_button_2_button_up():
	open_species_window(MapGlobal.current_selected_species) # The species window is already open, but it shouldn't matter because it just sets it to visible doesn't create a new one. This populates the window too.



func _on_previous_time_button_button_up():
	var all_maps = MapData.get_children()
	var lowest_map_id = all_maps[0].map_id
	if MapGlobal.current_map_id > lowest_map_id:
		MapGlobal.current_map_id -= 1
	refresh_map()



func _on_next_time_button_button_up():
	var all_maps = MapData.get_children()
	var highest_map_id = all_maps[all_maps.size() - 1].map_id
	if MapGlobal.current_map_id < highest_map_id:
		MapGlobal.current_map_id += 1
	refresh_map()



################################################################################
# Called internally from signal functions:



func close_loi_window():
	loi_window.visible = false
	MapGlobal.can_move_camera = true
	MapGlobal.is_loi_focused = false
	timeline_control.visible = true



func close_zone_window():
	zone_window.visible = false
	MapGlobal.can_move_camera = true
	MapGlobal.zones_hovering = []
	timeline_control.visible = true



func close_species_window():
	species_window.visible = false
	MapGlobal.is_viewing_species = false



func summon_zone_picker():
	zone_picker_control.visible = true
	zone_picker_control.global_position = get_global_mouse_position()



func clear_hovered_zones():
	MapGlobal.zones_hovering = []
	for zone in zones.get_children():
		zone.is_hovered = false



func refresh_map():
	# First clear zones and buttons
	for this_zone in zones.get_children():
		this_zone.queue_free()
	for this_loi in locations_of_interest.get_children():
		this_loi.queue_free()
	# Then:
	load_current_map()
	load_zones()
	load_buttons()
