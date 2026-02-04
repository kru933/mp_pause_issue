extends Node

signal changed_zone(zone : String, client_id : int)

var current_zone := {}

func _ready()->void:
	changed_zone.connect(func(z : String, id : int): current_zone[id] = z)

func _dummy()->void:
	changed_zone.emit("", 1)
