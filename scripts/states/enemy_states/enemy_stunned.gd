extends State
class_name EnemyStunned

var actor: Enemy:
	get():
		return _actor as Enemy


func enter_state(_msg := {}) -> void:
	if actor.sprite.sprite_frames.has_animation("hit"):
		actor.sprite.play("hit")

func physics_update(delta: float) -> void:
	if not actor.is_on_floor():
		actor.velocity.y += 980.0 * delta

	actor.knock = move_toward(actor.knock, 0.0, 1500.0 * delta)
	actor.velocity.x = actor.knock

	if actor.health <= 0:
		state_machine.change_state("EnemyDead")
		return

	if not actor.is_stunned:
		if actor.is_on_floor():
			state_machine.change_state("EnemyIdle")
		else:
			state_machine.change_state("EnemyFall")
		return

	actor.move_and_slide()
