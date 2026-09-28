extends Node
class_name Room

const HEART_DROP = preload("uid://cvvxfxr3biyta")

@export var player: Player
@export var room_num: int = -1
@export var heart_bar: Node2D

@export var yield_prompt: Control
@export var yes_button: Button
@export var no_button: Button
@export var speed_run_timer: Label

@export var sfx_player_walk_echo: AudioStreamPlayer
@export var door: Door
@export var main_menu: StringName = &""
@export var parallax: ParallaxController
@export var play_space: Node2D

var room: String
var uid: String

@export var take_heart: bool = false
@export var taken_item: String

@export var tiles_x: int = 0
@export var tiles_y: int = 0

var can_interact: bool = true

func _ready() -> void:
	Music.switch_player(room_num)
	SpeedRunTimerGlobal.is_paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	yield_prompt.visible = false
	
	door.trigger_door.connect(_on_door_triggered)
	yes_button.pressed.connect(_on_yes_pressed)
	no_button.pressed.connect(_on_no_pressed)
	
	player.set_camera_boundaries(tiles_x, tiles_y)
	player.reset_room.connect(_on_reset_pressed)
	
	parallax.set_tiles(tiles_x, tiles_y)
	
	uid = ResourceUID.id_to_text(ResourceLoader.get_resource_uid(scene_file_path))
	
	
	player.set_health.connect(heart_bar.set_health)
	player.set_max_health.connect(heart_bar.set_max_health)
	
	heart_bar.set_health(player.health)
	heart_bar.set_max_health(player.max_health)
	door.is_open = false
	SignalBus.set_room_num.emit(room_num)
	
	for child in play_space.get_children(true):
		if child is Enemy:
			child.spawn_on_death.connect(_on_spawn_item)

	for child in play_space.get_children(true):
		if child is Enemy:
			child.set_target(player)

func _process(_delta: float) -> void:
	if not can_interact:
		return
	speed_run_timer.visible = SpeedRunTimerGlobal.is_speedrunning
	speed_run_timer.text = "%.2f" % SpeedRunTimerGlobal.time 
	if Input.is_action_just_pressed("reset"):
		can_interact = false
		SceneTransition.load_scene(uid)
		can_interact = true

func _on_door_triggered(next_room: String) -> void:
	if can_interact:
		door.is_open = true
		Music.switch_player(room_num + 8)
		can_interact = false
		yield_prompt.visible = true
		room = next_room
		get_tree().paused = true
		yes_button.grab_focus()

func _on_yes_pressed() -> void:
	sfx_player_walk_echo.play()
	can_interact = false
	if take_heart:
		SaveLoad._set_dictionary_value(SaveLoad.max_health_key, SaveLoad.get_key_value(SaveLoad.max_health_key) - 1)
	match taken_item:
		"double jump":
			SaveLoad._set_dictionary_value(SaveLoad.double_jump_key, false)
		"wall jump":
			SaveLoad._set_dictionary_value(SaveLoad.wall_jump_key, false)
		"sword":
			SaveLoad._set_dictionary_value(SaveLoad.sword_key, false)
		"shield":
			SaveLoad._set_dictionary_value(SaveLoad.shield_key, false)
		"dash":
			SaveLoad._set_dictionary_value(SaveLoad.dash_key, false)
		_:
			pass # default case
	door.set_active(false)
	get_tree().paused = false
	yield_prompt.visible = false
	SceneTransition.load_scene(room)

func _on_no_pressed() -> void:
	door.is_open = false
	Music.switch_player(room_num)
	yield_prompt.visible = false
	door.set_active(true)
	get_tree().paused = false
	can_interact = true

func _on_reset_pressed() -> void:
	can_interact = false
	get_tree().paused = false
	SceneTransition.load_scene(uid)

func _on_spawn_item(pos: Vector2, item: PackedScene, chance: int) -> void:
	call_deferred("spawn_item", pos, item, chance)

func spawn_item(pos: Vector2, _item: PackedScene, chance: int) -> void:
	if _item and randi_range(0, 100) < chance:
		var item = _item.instantiate() as RigidBody2D
		add_child(item)
		item.global_position = pos
		var force = Vector2(randf_range(-100, 100), randf_range(-50, -100))
		item.apply_impulse(force)
