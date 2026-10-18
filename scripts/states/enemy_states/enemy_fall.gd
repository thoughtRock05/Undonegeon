extends State
class_name EnemyFall

var actor: Enemy:
	get():
		return _actor as Enemy


func enter_state(_msg := {}) -> void:
	if actor.sprite.sprite_frames.has_animation("fall"):
		actor.sprite.play("fall")

func physics_update(delta: float) -> void:
	actor.velocity.y += 980.0 * delta

	if actor.health <= 0:
		state_machine.change_state("EnemyDead")
		return

	if actor.is_on_floor():
		if actor.target:
			state_machine.change_state("EnemyAlert")
		else:
			state_machine.change_state("EnemyIdle")
		return

	actor.move_and_slide()
