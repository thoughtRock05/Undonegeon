extends CharacterBody2D
class_name Player

signal reset_room
signal set_health(health: int)
@warning_ignore("unused_signal") signal set_max_health(max_health: int)

@export_group("Player Tuning")
@export var SPEED = 375.0
@export var WALK_DECEL = 1200.0
@export var JUMP_VELOCITY = -445.0
@export var WALL_JUMP_VELOCITY = -450.0
@export var WALL_JUMP_PUSH = 350.0
@export var WALL_SLIDE_SPEED = 90.0
@export var DASH_SPEED = 650.0
@export var DASH_DURATION = 0.35
@export var DASH_DECEL = 2500.0
@export var ATTACK_DECEL = 700.0
@export var KNOCKBACK_DECEL = 1200.0
@export var I_FRAMES_DURATION = 0.5
@export var DASH_ATTACK_SPEED = 275.0
@export var WALL_DETATCH = 100.0
enum DashType {NONE, GROUND, AIR}

var has_double_jump: bool
var has_wall_jump: bool
var has_sword: bool
var has_shield: bool
var has_dash: bool
var has_wall_cling: bool = true

@export_group("Children")
@export var player_sprite: AnimatedSprite2D
@export var player_camera: Camera2D
@export var player_hitbox: PlayerHitBox
@export var sword_hit_box: SwordHitBox
@export var shield_sprite: Sprite2D
@export var shield_collision: CollisionShape2D
@export var shield_hitbox: Area2D

@export_group("Timers")
@export var coyote_timer: Timer
@export var buffer_timer: Timer
@export var dash_timer: Timer
@export var wall_jump_timer: Timer
@export var attack_timer: Timer
@export var i_frame_timer: Timer
@export var wall_slide_timer: Timer

@export_group("SFX")
@export var sfx_player_dash: AudioStreamPlayer
@export var sfx_player_death: AudioStreamPlayer
@export var sfx_player_hurt: AudioStreamPlayer
@export var sfx_player_jump: AudioStreamPlayer
@export var sfx_player_walk: AudioStreamPlayer
@export var sfx_player_wall_slide: AudioStreamPlayer
@export var sfx_heart_pickup: AudioStreamPlayer
@export var sfx_sword_swing: AudioStreamPlayer

@export_group("State Machine")
@export var state_machine: StateMachine

var jump_count = 0
var health: int
var max_health: int
var can_dash: bool = true
var dash_dir: Vector2 = Vector2.RIGHT
var is_invincible: bool = false
var knock_v: Vector2 = Vector2.ZERO
var current_dash: DashType = DashType.NONE
var is_dash_attack: bool = false

func _ready() -> void:
	has_double_jump = SaveLoad.get_key_value(SaveLoad.double_jump_key)
	has_wall_jump = SaveLoad.get_key_value(SaveLoad.wall_jump_key)
	has_sword = SaveLoad.get_key_value(SaveLoad.sword_key)
	has_shield = SaveLoad.get_key_value(SaveLoad.shield_key)
	has_dash = SaveLoad.get_key_value(SaveLoad.dash_key)
	
	max_health = SaveLoad.get_key_value(SaveLoad.max_health_key)
	health = max_health
	
	sword_hit_box.monitorable = false
	sword_hit_box.monitoring = false
	player_sprite.frame_changed.connect(_on_frame_changed)
	player_hitbox.area_entered.connect(hit)
	sword_hit_box.area_entered.connect(_on_sword_hit_box_area_entered)
	shield_hitbox.area_entered.connect(_on_shield_hitbox_area_entered)
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	i_frame_timer.timeout.connect(_on_i_frame_timer_timeout)
	player_sprite.position.x = 11.0
	sword_hit_box.position.x = 30.0
	
	state_machine.init(self)

func _physics_process(delta: float) -> void:
	if is_on_floor() and dash_timer.is_stopped() and current_dash != DashType.GROUND:
		can_dash = true
		current_dash = DashType.NONE
	var dir = Input.get_axis("left","right")
	peek_camera(delta)
	update_facing(dir)
	update_shield()
	state_machine.physics_update(delta)
	move_and_slide()


func peek_camera(delta) -> void:
	var look_y: float = 0
	if Input.is_action_pressed("up"):
		look_y -= 125
	elif Input.is_action_pressed("down"):
		look_y += 125
	player_camera.position.y = lerp(player_camera.position.y, look_y, 10 * delta)

func add_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _on_frame_changed() -> void:
	if player_sprite.animation == "dash":
		var last_frame: int = player_sprite.sprite_frames.get_frame_count("dash") - 1
		if player_sprite.frame == last_frame:
			player_sprite.pause()
	
	if player_sprite.animation == "attack":
		if player_sprite.frame == 2:
			sword_hit_box.monitoring = true
			sword_hit_box.monitorable = true
		if player_sprite.frame == 4:
			sword_hit_box.monitoring = false
			sword_hit_box.monitorable = false

func update_facing(dir: float):
	var current_state_name = state_machine.current_state.name
	if current_state_name in ["PlayerDash", "PlayerAttack", "PlayerDead"]:
		return
	if current_state_name == "PlayerJump" and velocity.x != 0:
		if velocity.x < 0:
			face_left()
		elif velocity.x > 0:
			face_right()
	elif dir != 0:
		if dir < 0:
			face_left()
		elif dir > 0:
			face_right()

func face_left() -> void:
	player_sprite.position.x = -21.0
	player_sprite.flip_h = true
	sword_hit_box.position.x = -37.0

func face_right() -> void:
	player_sprite.position.x = 21.0
	player_sprite.flip_h = false
	sword_hit_box.position.x = 37.0

func update_shield():
	var shielding = (state_machine.current_state.name == "PlayerShield")
	
	shield_sprite.visible = shielding or is_dash_attack
	shield_collision.disabled = not (shielding or is_dash_attack)
	shield_hitbox.monitorable = shielding
	shield_hitbox.monitoring = shielding


func hit(area: Area2D):
	if area is HeartBox:
		health_pickup()
		return
	if area is AcidPit:
		die()
		return
	if area is not EnemyHitBox:
		return
	
	var current_state_name = state_machine.current_state.name
	if is_invincible or current_state_name == "PlayerShield" or current_state_name == "PlayerDead" or (current_state_name == "PlayerAttack" and abs(velocity.x) > SPEED):
		return
	if not sfx_player_hurt.is_playing():
		sfx_player_hurt.play()
	
	health -= 1
	set_health.emit(health)
	
	if health <= 0:
		die()
	else:
		if current_state_name == "PlayerDash":
			dash_timer.stop()
			if current_dash == DashType.GROUND:
				can_dash = true
				current_dash = DashType.NONE
		
		state_machine.change_state("PlayerStun")
		var knock_dir: float = sign(global_position.x - area.global_position.x)
		if knock_dir == 0.0:
			knock_dir = 1
		knock_v.x = knock_dir * 500.0
		velocity.y = -250.0
		
		is_invincible = true
		i_frame_timer.start()
		
		await get_tree().create_timer(I_FRAMES_DURATION).timeout
		if state_machine.current_state.name == "PlayerStun":
			state_machine.change_state("PlayerIdle")

func health_pickup():
	sfx_heart_pickup.play()
	health += 1
	if health > max_health:
		health = max_health
	set_health.emit(health)

func die() -> void:
	if state_machine.current_state.name != "PlayerDead":
		set_health.emit(0)
		state_machine.change_state("PlayerDead")
		velocity = Vector2(0.0, -200.0)
		sfx_player_death.play()
		await player_sprite.animation_finished
		reset_room.emit()

func set_camera_boundaries(x: int, y: int) -> void:
	var tile_size: int = 32
	player_camera.limit_top = tile_size * -1
	player_camera.limit_bottom = (y + 1) * tile_size
	player_camera.limit_left = tile_size * -1
	player_camera.limit_right = (x + 1) * tile_size
	
	player_camera.LEVEL_MAX_WIDTH = (x + 2) * tile_size
	player_camera.LEVEL_MAX_HEIGHT = (y + 2) * tile_size
	
	player_camera._adjust_camera_zoom()
	
	player_camera.reset_smoothing()

func _on_dash_timer_timeout() -> void:
	if current_dash == DashType.GROUND:
		can_dash = true
		current_dash = DashType.NONE

func _on_i_frame_timer_timeout() -> void:
	is_invincible = false

func _on_sword_hit_box_area_entered(area: Area2D) -> void:
	if area is EnemyHitBox:
		area.get_parent().hit(sword_hit_box)

func check_inputs() -> bool:
	if Input.is_action_just_pressed("shield") and has_shield:
		state_machine.change_state("PlayerShield")
		return true
	elif Input.is_action_just_pressed("dash") and has_dash and can_dash:
		state_machine.change_state("PlayerDash")
		return true
	elif Input.is_action_just_pressed("attack") and has_sword:
		state_machine.change_state("PlayerAttack")
		return true
	return false

func _on_shield_hitbox_area_entered(area: Area2D) -> void:
	var current_state_name = state_machine.current_state.name
	if current_state_name == "PlayerShield":
		if area is EnemyHitBox:
			area.get_parent().hit(shield_hitbox)
