extends CharacterBody2D
class_name Character

@export var movement_speed: float = 300.0
@export var jump_velocity: float = -1100.0
@export var gravity_multiplier: float = 3

@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D
@onready var area_collision_polygon: CollisionPolygon2D = $Area2D/CollisionPolygon2D
@onready var polygon: Polygon2D = $Polygon2D

var _direction: float = 0
var _in_contact: Dictionary[int, Character] = {}

func _ready() -> void:
	collision_polygon.polygon = polygon.polygon
	area_collision_polygon.polygon = polygon.polygon

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
		
func _cut() -> void:
	if _in_contact.size() > 0:
		for c in _in_contact.values():
			c._perform_cut(polygon, rotation)

func _perform_cut(poly: Polygon2D, rot: float) -> void:
	var t1 = Transform2D(rot, poly.global_position)
	var clipping_points = t1 * poly.polygon
	var t2 = Transform2D(rotation, polygon.global_position)
	var target_points = t2 * polygon.polygon
	
	var res = Geometry2D.clip_polygons(target_points, clipping_points)

	# TODO: If the final object is too small, it should automatically revert back to initial shape
	# TODO: The smaller objects should be transformed into rigidbodies and fall to the ground and slowly fade out	
	# TODO: The biggest of them should be the CharacterBody3D
	if res.size() > 1:
		push_warning("Clip polygons operation resulted in more %d objects, only 1 will be used!" % [res.size()])
	
	if res.size() > 0:
		var result_points = []
		for raw_point in res[0]:
			var point = \
				(raw_point - polygon.global_position).rotated(-rotation)
			result_points.append(point)
		
		area_collision_polygon.set_deferred('polygon', result_points)
		collision_polygon.set_deferred('polygon', result_points)
		polygon.set_deferred("polygon", result_points)
		polygon.rotation -= polygon.rotation

func _on_area_2d_body_entered(body: Node2D) -> void:
	var id = body.get_instance_id()
	
	if body is Character and id != get_instance_id():
		_in_contact[id] = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	var id = body.get_instance_id()
	
	if body is Character and _in_contact.has(id):
		_in_contact.erase(id)
