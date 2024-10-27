extends Node



signal opening_species_window(species_name)
signal inspecting_zones()
signal opening_clickdrag_window(window_name)



func open_species_window(species_name):
	opening_species_window.emit(species_name)


func inspect_zones():
	inspecting_zones.emit()



func open_clickdrag_window(window_name):
	opening_clickdrag_window.emit(window_name)
