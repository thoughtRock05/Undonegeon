extends State
class_name PlayerWalk

var actor: Player:
	get():
		return _actor as Player

var step_distance_accumulator: float = 0.0
const STEP_DISTANCE: float = 65.0
var was_on_floor: bool = true

func enter_state(_msg := {}) -> void:
	actor.player_sprite.play("walk")
	step_distance_accumulator = 0.0

func physics_update(delta: float) -> void:
	var dir = Input.get_axis("left", "right")
	if dir != 0:
		actor.velocity.x = dir * actor.SPEED
	actor.add_gravity(delta)
	
	if actor.is_on_floor() and dir != 0:
		step_distance_accumulator += abs(actor.velocity.x) * delta
		if step_distance_accumulator >= STEP_DISTANCE:
			step_distance_accumulator = 0.0
			actor.sfx_player_walk.pitch_scale = randf_range(0.95, 1.05)
			actor.sfx_player_walk.play()
	
	if actor.is_on_floor():
		actor.jump_count = 0
		actor.coyote_timer.start()
	
	if was_on_floor and not actor.is_on_floor():
		actor.coyote_timer.start()
	
	was_on_floor = actor.is_on_floor()
	
	if actor.check_inputs():
		return
	elif Input.is_action_just_pressed("jump") or (not actor.coyote_timer.is_stopped() and not actor.buffer_timer.is_stopped()):
		actor.coyote_timer.stop()
		state_machine.change_state("PlayerJump")
	elif dir == 0.0:
		state_machine.change_state("PlayerIdle")
	elif not actor.is_on_floor():
		actor.jump_count += 1
		state_machine.change_state("PlayerFall")
