extends State
class_name PlayerStun

var actor: Player:
	get():
		return _actor as Player


func enter_state(_msg := {}) -> void:
	actor.player_sprite.play("hurt")

func physics_update(delta: float) -> void:
	actor.knock_v.x = move_toward(actor.knock_v.x, 0.0, actor.KNOCKBACK_DECEL * delta)
	actor.velocity.x = actor.knock_v.x
	actor.add_gravity(delta)
