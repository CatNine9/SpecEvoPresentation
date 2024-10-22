extends Node



@onready var shape = $Shape



var map_id = 1
var map_year = 100000
var map_start_position = Vector2(1812, 1340)
var map_sprite_nw = preload("res://Maps/100000 New North Winter.png")
var map_sprite_sw = preload("res://Maps/100000 New South Winter.png")
var map_lois = []
var map_zones = []
