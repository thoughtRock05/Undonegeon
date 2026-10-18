extends State
class_name EnemyIdle

var actor: Enemy:
	get():
		return _actor as Enemy

func enter_state(_msg := {}) -> void:
	actor.velocity.x = 0.0
	if actor.sprite.sprite_frames.has_animation("idle"):
		actor.sprite.play("idle")

func physics_update(delta: float) -> void:
	if not actor.is_on_floor():
		actor.velocity.y += 980.0 * delta

	if actor.health <= 0:
		state_machine.change_state("EnemyDead")
		return

	if actor.is_stunned:
		state_machine.change_state("EnemyStunned")
		return

	if actor.target:
		var distance = actor.global_position.distance_to(actor.target.global_position)
		if distance <= actor.target_threshold:
			state_machine.change_state("EnemyAlert")
			return

	if actor.dir != 0.0 and actor.is_on_floor():
		state_machine.change_state("EnemyWalk")

	actor.move_and_slide()
