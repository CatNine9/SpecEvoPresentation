extends Button



@onready var species_name_label = $SpeciesNameLabel



func _on_button_up():
	if not MapGlobal.is_ui_focused:
		GlobalSignals.open_species_window(species_name_label.text)
