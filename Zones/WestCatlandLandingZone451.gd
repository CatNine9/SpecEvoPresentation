extends Node



@onready var zone_shape_polygon = $ZoneShapePolygon



var zone_name = "West Catland Landing Zone 451 Yh"
var zone_image = preload("res://Zones/LandingSiteZoneHighAlt451Placeholder.png")
# Need an array to store all the locations and hidden locations in a zone.
# Positions here are for the zone window view, not the world map view.
# Hidden locations are locations that don't show on the map. They can only be discovered in the zone window.
var zone_locations = ["Landing Site 450 Yh"]
var zone_hidden_locations = []
