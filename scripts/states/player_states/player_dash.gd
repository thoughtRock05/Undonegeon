extends State
class_name PlayerDash

var actor: Player = _actor as Player

func enter_state(msg := {}) -> void:
	var input_x: float = Input.get_axis("left", "right")
	
	if msg.has("wall_normal"):
		var wall_normal = msg.wall_normal
		actor.dash_dir = Vector2(wall_normal.x, 0).normalized()
	elif input_x != 0:
		actor.dash_dir = Vector2(input_x, 0).normalized()
	else:
		var dash_x = -1 if actor.player_sprite.flip_h else 1
		actor.dash_dir = Vector2(dash_x, 0)
	
	if actor.dash_dir.x < 0:
		actor.face_left()
	elif actor.dash_dir.x > 0:
		actor.face_right()
	
	if actor.is_on_floor():
		actor.current_dash = actor.DashType.GROUND
	else:
		actor.current_dash = actor.DashType.AIR
	
	actor.player_sprite.play("dash")
	actor.can_dash = false
	actor.velocity = actor.dash_dir * actor.DASH_SPEED
	actor.velocity.y = 0
	
	if not actor.sfx_player_dash.is_playing():
		actor.sfx_player_dash.play()
	actor.dash_timer.start(actor.DASH_DURATION)

func physics_update(delta: float) -> void:
	var dir = Input.get_axis("left", "right")
	
	if Input.is_action_just_pressed("shield") and actor.has_shield:
		actor.dash_timer.stop()
		if actor.current_dash == actor.DashType.GROUND:
			actor.can_dash = true
			actor.current_dash = actor.DashType.AIR
	
	if Input.is_action_just_pressed("attack") and actor.has_sword:
		actor.dash_timer.stop()
		if actor.current_dash == actor.DashType.GROUND:
			actor.can_dash = true
			actor.current_dash = actor.DashType.AIR
		actor.velocity = actor.dash_dir * actor.DASH_SPEED * 0.85
		state_machine.change_state("PlayerAttack")
		return
	
	if not actor.dash_timer.is_stopped():
		actor.velocity = actor.dash_dir * actor.DASH_SPEED
		actor.velocity.y = 0
	else:
		actor.add_gravity(delta)
		var target = dir * actor.SPEED
		actor.velocity.x = move_toward(actor.velocity.x, target, actor.DASH_DECEL * delta)
		
		if abs(actor.velocity.x) > actor.SPEED:
			if dir != 0:
				actor.velocity.x = move_toward(actor.velocity.x, dir * actor.SPEED, actor.DASH_DECEL * delta)
			else:
				actor.velocity.x = move_toward(actor.velocity.x, 0, actor.DASH_DECEL * delta)
		
		if actor.is_on_floor():
			if dir == 0.0:
				state_machine.change_state("PlayerIdle")
			else:
				state_machine.change_state("PlayerWalk")
		elif actor.wall_slide_ray_cast.is_colliding():
			state_machine.change_state("PlayerFall")
		else:
			state_machine.change_state("PlayerFall")
