extends Node



signal opening_loi_window(loi_name)
signal opening_species_window(species_name)
signal inspecting_zones()



func open_loi_window(loi_name):
	opening_loi_window.emit(loi_name)



func open_species_window(species_name):
	opening_species_window.emit(species_name)


func inspect_zones():
	inspecting_zones.emit()
