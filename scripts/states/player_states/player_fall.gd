extends State
class_name PlayerFall

var actor: Player = _actor as Player

func enter_state(_msg := {}) -> void:
	actor.player_sprite.play("fall")
	
func physics_update(delta: float) -> void:
	var dir = Input.get_axis("left", "right")
	actor.add_gravity(delta)
	
	if abs(actor.velocity.x) > actor.SPEED:
		if dir == 0:
			actor.velocity.x = move_toward(actor.velocity.x, 0, actor.DASH_DECEL * delta)
		else:
			actor.velocity.x = move_toward(actor.velocity.x, dir * actor.SPEED, actor.DASH_DECEL * delta)
	else:
		if dir != 0:
			actor.velocity.x = move_toward(actor.velocity.x, dir * actor.SPEED, actor.SPEED * 8.0 * delta)
		else:
			actor.velocity.x = move_toward(actor.velocity.x, 0, actor.WALK_DECEL * delta)
	
	if Input.is_action_just_pressed("dash") and actor.has_dash and actor.can_dash:
		state_machine.change_state("PlayerDash")
	elif Input.is_action_just_pressed("attack") and actor.has_sword:
		state_machine.change_state("PlayerAttack")
	elif Input.is_action_just_pressed("jump") and (not actor.coyote_timer.is_stopped() or actor.jump_count < 1 + int(actor.has_double_jump)):
		actor.coyote_timer.stop()
		state_machine.change_state("PlayerJump")
	elif actor.has_wall_jump and not actor.is_on_floor() and actor.is_on_wall():
		state_machine.change_state("PlayerWallSlide")
	elif actor.is_on_floor():
		actor.jump_count = 0
		if dir == 0.0:
			state_machine.change_state("PlayerIdle")
		else:
			state_machine.change_state("PlayerWalk")
