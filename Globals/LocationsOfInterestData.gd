extends Node



var landing_site_450yh = null
var dome_surroundings_450yh = null



var all_unaltered_loi_data = []



func _ready():
	load_all_lois()



func load_all_lois():
	landing_site_450yh = preload("res://Locations/LandingSite451Yh.tscn").instantiate()
	dome_surroundings_450yh = preload("res://Locations/DomeSurroundings451Yh.tscn").instantiate()
	add_child(landing_site_450yh)
	add_child(dome_surroundings_450yh)
	for this_loi in get_children():
		all_unaltered_loi_data.append(this_loi)



func load_location_of_interest(location_name):
	for this_location in get_children():
		if this_location.loi_name == location_name:
			return this_location
