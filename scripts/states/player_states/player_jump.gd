extends State
class_name PlayerJump

var actor: Player = _actor as Player

func enter_state(msg := {}) -> void:
	if msg.has("wall_normal"):
		var wall_normal = msg.wall_normal
		actor.velocity.y = actor.WALL_JUMP_VELOCITY
		actor.velocity.x = wall_normal.x * actor.WALL_JUMP_PUSH
		actor.jump_count = 1
		actor.wall_jump_timer.start()
		
		if actor.velocity.x < 0:
			actor.face_left()
		else:
			actor.face_right()
	else:
		actor.velocity.y = actor.JUMP_VELOCITY
		actor.jump_count += 1
		
	actor.sfx_player_jump.play()
	actor.buffer_timer.stop()
	actor.player_sprite.play("jump")

func physics_update(delta: float) -> void:
	actor.add_gravity(delta)
	
	if not actor.wall_jump_timer.is_stopped():
		pass
	else:
		var dir = Input.get_axis("left", "right")
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
	
	var dir_check = Input.get_axis("left", "right")
	
	if Input.is_action_just_pressed("dash") and actor.has_dash and actor.can_dash:
		state_machine.change_state("PlayerDash")
	elif Input.is_action_just_pressed("attack") and actor.has_sword:
		state_machine.change_state("PlayerAttack")
	elif Input.is_action_just_pressed("jump") and actor.jump_count < (1 + int(actor.has_double_jump)):
		state_machine.change_state("PlayerJump")
	elif actor.has_wall_jump and not actor.is_on_floor() and actor.is_on_wall() and actor.velocity.y > 0:
		state_machine.change_state("PlayerWallSlide")
	elif actor.velocity.y >= 0:
		state_machine.change_state("PlayerFall")
	elif actor.is_on_floor():
		if dir_check == 0.0:
			state_machine.change_state("PlayerIdle")
		else:
			state_machine.change_state("PlayerWalk")
