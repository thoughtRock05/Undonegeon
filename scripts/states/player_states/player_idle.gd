extends State
class_name PlayerIdle

var actor: Player:
	get():
		return _actor as Player

var was_on_floor: bool = true

func enter_state(_msg := {}) -> void:
	actor.player_sprite.play("idle")
	if actor.is_on_floor():
		actor.jump_count = 0
		actor.coyote_timer.start()

func physics_update(delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, actor.WALK_DECEL * delta)
	actor.add_gravity(delta)
	
	var dir = Input.get_axis("left", "right")
	
	if was_on_floor and not actor.is_on_floor():
		actor.coyote_timer.start()
	
	was_on_floor = actor.is_on_floor()
	
	if actor.check_inputs():
		return
	elif Input.is_action_just_pressed("jump") or (not actor.coyote_timer.is_stopped() and not actor.buffer_timer.is_stopped()):
		actor.coyote_timer.stop()
		state_machine.change_state("PlayerJump")
	elif dir != 0.0:
		state_machine.change_state("PlayerWalk")
	elif not actor.is_on_floor():
		actor.jump_count += 1
		state_machine.change_state("PlayerFall")
