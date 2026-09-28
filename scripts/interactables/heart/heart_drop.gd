extends RigidBody2D
class_name HeartPickup

@export var animated_sprite_2d: AnimatedSprite2D
@export var audio_stream_player: AudioStreamPlayer2D
@export var heart_box: HeartBox
var collected: bool = false

func _ready() -> void:
	animated_sprite_2d.play()
	audio_stream_player.play()
	heart_box.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
	if collected:
		return
	if area is PlayerHitBox:
		var parent: Node = area.get_parent() as Player
		collected = true
		parent.health_pickup()
		queue_free()
