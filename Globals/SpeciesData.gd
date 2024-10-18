extends Node



var domestic_cat = null
var house_sparrow = null
var stinging_nettle = null
var catmint = null



var all_unaltered_species_data = []



func _ready():
	load_all_species()



func load_all_species():
	domestic_cat = preload("res://Species/DomesticCat.tscn").instantiate()
	house_sparrow = preload("res://Species/HouseSparrow.tscn").instantiate()
	stinging_nettle = preload("res://Species/StingingNettle.tscn").instantiate()
	catmint = preload("res://Species/Catmint.tscn").instantiate()
	add_child(domestic_cat)
	add_child(house_sparrow)
	add_child(stinging_nettle)
	add_child(catmint)
	for this_species in get_children():
		all_unaltered_species_data.append(this_species)



func load_species(species_name):
	for this_species in get_children():
		if this_species.species_name == species_name:
			return this_species
