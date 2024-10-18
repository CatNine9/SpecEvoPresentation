extends Node



@onready var location_shape_polygon = $LocationShapePolygon
@onready var species_cats_1_polygon = $Cats1
@onready var species_sparrows_1_polygon = $Sparrows1



var loi_name = "Dome Surroundings 450 Yh"
var loi_icon = null
var loi_image = preload("res://Locations/DomeSurroundingsPlaceholder.png")
var loi_zone_view_sprite = null
var loi_zone_view_sprite_position = Vector2()
var loi_locations = []
var loi_species = null



func _ready():
	loi_species = [["Domestic Cat", species_cats_1_polygon],["House Sparrow", species_sparrows_1_polygon]]
