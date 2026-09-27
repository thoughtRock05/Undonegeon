extends State
class_name PlayerWallSlide

var actor: Player = _actor as Player

func enter_state(_msg := {}) -> void:
	actor.player_sprite.play("wall_cling")
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
	else:
		actor.velocity.y = min(actor.velocity.y, actor.WALL_SLIDE_SPEED)
		actor.add_gravity(delta)
		if not actor.sfx_player_wall_slide.is_playing():
			actor.sfx_player_wall_slide.play()
	
	if dir != 0 and sign(dir) == sign(wall_normal.x):
		actor.velocity.x = wall_normal.x * actor.WALL_DETATCH
		state_machine.change_state("PlayerFall")
	elif Input.is_action_just_pressed("jump"):
		state_machine.change_state("PlayerJump", {"wall_normal": wall_normal})
	elif Input.is_action_just_pressed("dash") and actor.has_dash and actor.can_dash:
		state_machine.change_state("PlayerDash", {"wall_normal": wall_normal})
	elif actor.is_on_floor():
		state_machine.change_state("PlayerIdle")
	elif not actor.is_on_wall():
		if actor.wall_slide_timer.is_stopped():
			actor.wall_slide_timer.start(0.08)
			await actor.wall_slide_timer.timeout
			if not actor.is_on_wall():
				state_machine.change_state("PlayerFall")
