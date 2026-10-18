extends State
class_name PlayerShield

var actor: Player:
	get():
		return _actor as Player


func enter_state(_msg := {}) -> void:
	actor.player_sprite.play("idle")

func physics_update(delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, actor.ATTACK_DECEL * delta)
	actor.add_gravity(delta)
	
	if not Input.is_action_pressed("shield") or not actor.has_shield:
		state_machine.change_state("PlayerIdle")
