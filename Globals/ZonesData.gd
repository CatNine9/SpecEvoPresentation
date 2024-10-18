extends Node



var west_catland_landing_zone_451 = null



var all_zones_unaltered = []


################################################################################



func _ready():
	west_catland_landing_zone_451 = preload("res://Zones/WestCatlandLandingZone451.tscn").instantiate()
	add_child(west_catland_landing_zone_451)
	for this_zone in get_children():
		all_zones_unaltered.append(this_zone)



func load_zone(zone_name):
	for this_zone in get_children():
		if this_zone.zone_name == zone_name:
			return this_zone
