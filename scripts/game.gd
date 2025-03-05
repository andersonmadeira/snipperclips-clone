extends Node2D
class_name Game

# CORE:
# TODO: Make the intersection area change color
# TODO: Implement cut action
# TODO: Implement revert action
# TODO: Implement feet of the characters (specially useful when on top of the other char just so it doesn't fall down)

# ADDITIONAL:
# TODO: Implement raise and crouch actions: When the player switches, the last position should remain
# TODO: Add interaction with rigidbodies
# TODO: Implement level of the basketball
# TODO: Implement level of the bird
# TODO: Implement level of the heart

# POLISH:
# TODO: Transform the cut pieces into rigidbodies and make them fall to the ground (ignoring other bodies) and fading out slowly
# TODO: Add some visual indication to show which character the player is controlling when it switches
# TODO: Add sprites for the eyes of the character

@export var characters: Array[Character]

var _character_index: int = 0
var _character: Character

func _ready() -> void:
	_character = characters[_character_index]
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("rotate_left"):
		_character._rotate(-1)
	if Input.is_action_pressed("rotate_right"):
		_character._rotate(1)
		
	var move_input = Input.get_axis("move_left", "move_right")
	_character._set_movement_direction(move_input)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_players"):
		# Reset input for previous player when we switch, just so it stops moving
		_character._set_movement_direction(0)
		# TODO: Also make it stay where it is, like crouching or raising states
		
		_character_index = wrapi(_character_index + 1, 0, characters.size())
		_character = characters[_character_index]
	if event.is_action_pressed("jump"):
		_character._jump()
	
	if event.is_action_pressed("cut"):
		_character._cut()
	
