extends State
class_name EnemyAlert

var actor: Enemy:
	get():
		return _actor as Enemy


func enter_state(_msg := {}) -> void:
	if actor.sfx_aggro:
		actor.sfx_aggro.play()
	
	if actor.sprite.sprite_frames.has_animation("alert"):
		actor.sprite.play("alert")

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
		if distance > actor.max_threshold:
			state_machine.change_state("EnemyIdle")
			return
		
		if abs(actor.global_position.x - actor.target.position.x) > 0.2:
			actor.dir = sign(actor.target.position.x - actor.position.x)
			actor.velocity.x = actor.dir * actor.SPEED
		else:
			actor.velocity.x = 0.0
		
		if actor.velocity.x != 0:
			actor.sprite.flip_h = actor.velocity.x > 0
		
	actor.move_and_slide()
