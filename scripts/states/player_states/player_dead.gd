extends State
class_name PlayerDead

var actor: Player:
	get():
		return _actor as Player


func enter_state(_msg := {}) -> void:
	actor.player_sprite.play("die")

func physics_update(delta: float) -> void:
	actor.add_gravity(delta)
