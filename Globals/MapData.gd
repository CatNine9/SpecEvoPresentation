extends Node



var map_450 = null
var map_100_k = null
var map_2_m = null
var map_10_m = null



var all_unaltered_map_data = []



func _ready():
	load_all_maps()



func load_all_maps():
	map_450 = preload("res://Maps/Map450.tscn").instantiate()
	map_100_k = preload("res://Maps/Map100k.tscn").instantiate()
	map_2_m = preload("res://Maps/Map2M.tscn").instantiate()
	map_10_m = preload("res://Maps/Map10M.tscn").instantiate()
	add_child(map_450)
	add_child(map_100_k)
	add_child(map_2_m)
	add_child(map_10_m)
	for this_map_data in get_children():
		all_unaltered_map_data.append(this_map_data)



func load_map_data(map_id):
	for this_map in get_children():
		if map_id == this_map.map_id:
			return this_map
