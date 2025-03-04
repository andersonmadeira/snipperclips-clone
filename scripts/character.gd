extends CharacterBody2D
class_name Character

@export var movement_speed: float = 300.0
@export var jump_velocity: float = -1100.0
@export var gravity_multiplier: float = 3

var _direction: float = 0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * 3 * delta

	if _direction:
		velocity.x = _direction * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed)

	move_and_slide()
		
func _rotate(amount_deg: float) -> void:
	rotate(deg_to_rad(amount_deg))
	
func _set_movement_direction(dir: int) -> void:
	_direction = sign(dir)
	
func _jump() -> void:
	if is_on_floor():
		velocity.y = jump_velocity
