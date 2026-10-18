extends State
class_name EnemyWalk

var actor: Enemy:
	get():
		return _actor as Enemy


func enter_state(_msg := {}) -> void:
	if actor.sprite.sprite_frames.has_animation("walk"):
		actor.sprite.play("walk")

func physics_update(delta: float) -> void:
	if not actor.is_on_floor():
		actor.velocity.y += 980.0 * delta

	if actor.health <= 0:
		state_machine.change_state("EnemyDead")
		return

	if actor.is_stunned:
		state_machine.change_state("EnemyStunned")
		return

	if actor.is_on_wall():
		actor.dir = actor.get_wall_normal().x

	actor.velocity.x = actor.dir * actor.SPEED

	if actor.velocity.x != 0:
		actor.sprite.flip_h = actor.velocity.x > 0

	if actor.target:
		var distance = actor.global_position.distance_to(actor.target.global_position)
		if distance <= actor.target_threshold:
			state_machine.change_state("EnemyAlert")
			return

	actor.move_and_slide()
