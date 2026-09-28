extends Node2D
class_name Door

const DOOR_CLOSED = preload("uid://kyv1nm3ioy0")
const DOOR_OPEN = preload("uid://bk66uajxkaxfj")
@export var sprite_2d: Sprite2D

signal trigger_door(room: String, take_heart, taken_item)
@export var trigger_area: Area2D
@export_file("*tscn") var next_room: String
@export var sfx_door: AudioStreamPlayer

var is_open: bool = false:
	set(value):
		is_open = value
		if is_open:
			sprite_2d.texture = DOOR_OPEN
		else:
			sprite_2d.texture = DOOR_CLOSED

func _ready() -> void:
	trigger_area.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is PlayerHitBox:
		sfx_door.play()
		trigger_door.emit(next_room)

func set_active(b: bool) -> void:
	trigger_area.monitoring = b
	trigger_area.monitorable = b
