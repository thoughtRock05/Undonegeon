extends State
class_name PlayerWallSlide

var actor: Player = _actor as Player

func enter_state(_msg := {}) -> void:
	actor.wall_slide_timer.stop()

func exit_state() -> void:
	if actor.sfx_player_wall_slide.is_playing():
		actor.sfx_player_wall_slide.stop()
	actor.wall_slide_timer.stop()

func physics_update(delta: float) -> void:
	var dir = Input.get_axis("left", "right")
	var wall_normal = actor.get_wall_normal()
	
	if actor.has_wall_cling and (dir != 0 and sign(dir) != sign(wall_normal.x)):
		actor.velocity.y = 0
		actor.velocity.x = 0
		if actor.sfx_player_wall_slide.is_playing():
			actor.sfx_player_wall_slide.stop()
		actor.player_sprite.play("wall_cling")
	else:
		actor.velocity.y = move_toward(actor.velocity.y, actor.WALL_SLIDE_SPEED, actor.WALL_SLIDE_ACCEL * delta)
		if not actor.sfx_player_wall_slide.is_playing():
			actor.sfx_player_wall_slide.play()
		actor.player_sprite.play("wall_slide")
	
	if dir != 0 and sign(dir) == sign(wall_normal.x):
		actor.velocity.x = wall_normal.x * actor.WALL_DETATCH
		state_machine.change_state("PlayerFall")
	elif Input.is_action_just_pressed("jump"):
		state_machine.change_state("PlayerJump", {"wall_normal": wall_normal})
	elif Input.is_action_just_pressed("dash") and actor.has_dash and actor.can_dash:
		state_machine.change_state("PlayerDash", {"wall_normal": wall_normal})
	elif actor.is_on_floor():
		state_machine.change_state("PlayerIdle")
	elif not actor.wall_slide_ray_cast.is_colliding():
		if actor.wall_slide_timer.is_stopped():
			actor.wall_slide_timer.start()
			await actor.wall_slide_timer.timeout
			if not actor.wall_slide_ray_cast.is_colliding():
				state_machine.change_state("PlayerFall")
