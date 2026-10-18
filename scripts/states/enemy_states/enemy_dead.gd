extends State
class_name EnemyDead

var actor: Enemy:
	get():
		return _actor as Enemy


func enter_state(_msg := {}) -> void:
	if actor.sprite.sprite_frames.has_animation("die"):
		actor.sprite.play("die")
	
	if actor.hitbox:
		actor.hitbox.set_deferred("monitorable", false)
		actor.hitbox.set_deferred("monitoring", false)
		
	actor.visible = false
	actor.collision_layer = 0
	actor.collision_mask = 0
	
	if actor.sfx_death:
		actor.sfx_death.play()
		
	actor.spawn_on_death.emit(actor.position, actor.item, actor.drop_chance)
	
	if actor.sfx_death:
		actor.sfx_death.finished.connect(actor.queue_free, CONNECT_ONE_SHOT)
	else:
		actor.queue_free()

func physics_update(_delta: float) -> void:
	pass
