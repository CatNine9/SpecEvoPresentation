extends Node



var west_catland_landing_zone_451 = null
var landing_site_451 = null
var dome_surroundings_451 = null



var all_zones_unaltered = []


################################################################################



func _ready():
	west_catland_landing_zone_451 = preload("res://Zones/WestCatlandLandingZone451.tscn").instantiate()
	landing_site_451 = preload("res://Zones/LandingSite451Yh.tscn").instantiate()
	dome_surroundings_451 = preload("res://Zones/DomeSurroundings451Yh.tscn").instantiate()
	add_child(west_catland_landing_zone_451)
	add_child(landing_site_451)
	add_child(dome_surroundings_451)
	for this_zone in get_children():
		all_zones_unaltered.append(this_zone)



func load_zone(zone_name):
	for this_zone in get_children():
		if this_zone.zone_name == zone_name:
			return this_zone
