extends Node
class_name StateMachine

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func init(actor: CharacterBody2D) -> void:
	for child in get_children():
		if child is State:
			child._actor = actor
			child.state_machine = self
			states[child.name] = child
	
	if initial_state:
		initial_state.enter_state()
		current_state = initial_state

func change_state(target_state: String, msg: Dictionary = {}) -> void:
	if not states.has(target_state):
		return
	
	if current_state:
		current_state.exit_state()
	
	current_state = states[target_state]
	current_state.enter_state(msg)

func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
