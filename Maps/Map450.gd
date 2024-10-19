extends Node



@onready var shape = $Shape



var map_id = 0
var map_year = 2425
var map_start_position = Vector2(1812, 1340)
var map_sprite_nw = preload("res://Maps/451Yh New Map North Winter.png")
var map_sprite_sw = preload("res://Maps/451Yh New Map South Winter.png")
var map_lois = [] #[[Vector2(1801,1351), "Landing Site 450 Yh"]]
var map_zones = ["West Catland Landing Zone 451 Yh"]
