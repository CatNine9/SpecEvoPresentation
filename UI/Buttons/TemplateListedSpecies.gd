extends Button



@onready var species_name_label = $SpeciesNameLabel



func _on_button_up():
	print("Button clicked")
	GlobalSignals.open_species_window(species_name_label.text)
