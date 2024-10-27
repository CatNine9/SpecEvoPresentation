extends Node



@onready var zone_shape_polygon = $ZoneShapePolygon
@onready var species_cats_1_polygon = $Cats1
@onready var species_sparrows_1_polygon = $Sparrows1



var zone_name = "Dome Surroundings 450 Yh"
var zone_image = preload("res://Zones/DomeSurroundingsPlaceholder.png")
var zone_sprite = null
var zone_sprite_position = Vector2()
var zones_in_this_zone = []
var zone_species = [["Domestic Cat", species_cats_1_polygon],["House Sparrow", species_sparrows_1_polygon]]
