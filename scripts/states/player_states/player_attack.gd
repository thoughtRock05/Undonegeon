extends State
class_name PlayerAttack

var actor: Player:
	get():
		return _actor as Player


func enter_state(_msg := {}) -> void:
	actor.sfx_sword_swing.play()
	actor.player_sprite.play("attack")
	if abs(actor.velocity.x) > actor.SPEED or not actor.is_on_floor():
		actor.is_dash_attack = true

func exit_state() -> void:
	actor.sword_hit_box.set_deferred("monitorable", false)
	actor.sword_hit_box.set_deferred("monitoring", false)
	actor.is_dash_attack = false

func physics_update(delta: float) -> void:
	var dir = Input.get_axis("left", "right")
	actor.add_gravity(delta)
	
	if abs(actor.velocity.x) > actor.DASH_ATTACK_SPEED or not actor.is_on_floor():
		actor.velocity.x = move_toward(actor.velocity.x, dir * actor.SPEED, actor.ATTACK_DECEL * delta)
	else:
		actor.velocity.x = move_toward(actor.velocity.x, 0, actor.WALK_DECEL * delta)
	
	if not actor.player_sprite.is_playing() or actor.player_sprite.animation != "attack":
		state_machine.change_state("PlayerIdle")
