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
	collision_polygon.one_way_collision = true

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
		for char in _in_contact.values():
			char._perform_cut(polygon)

func _perform_cut(poly: Polygon2D) -> void:
	# 1st attempt
	#var offset_poly = Polygon2D.new()
	#offset_poly.global_position = Vector2.ZERO
	#var new_values = []
	#for point in poly.polygon:
		#new_values.append(point + poly.global_position)
	#
	#var res = Geometry2D.clip_polygons(new_values, polygon.polygon)
	#
	#print(res)
	
	# 2nd attempt
	#var offset_poly = Transform2D(0, poly.global_position) * poly.polygon
	#var res = Geometry2D.clip_polygons(offset_poly, polygon.polygon)
	#
	#if res.size() > 0:
		#var res2 = Transform2D(0, -poly.global_position) * res[0]
		#polygon.set_deferred('polygon', res2)
		##polygon.transform
		#print(res2)
	#else:
		#print('Failed!')
	#area_collision_polygon.set_deferred('polygon', res[0])
	#collision_polygon.set_deferred('polygon', res[0])
	
	# 3rd attempt - KINDA WORKS
	var offset_poly = Polygon2D.new()
	var points = []
	for p in poly.polygon:
		points.append(p + poly.global_position)
		
	var points2 = []
	for p in polygon.polygon:
		points2.append(p + polygon.global_position)
	
	var res = Geometry2D.clip_polygons(points2, points)
	
	if res.size() > 0:
		var points3 = []
		for p in res[0]:
			points3.append(p - polygon.global_position)
		
		$Line2D.points = points3
	
	print(res)
	

#func _perform_cut(points: PackedVector2Array, global_pos: Vector2) -> void:
	#var offset_points = Transform2D(0, global_pos) * points
	#var res = Geometry2D.exclude_polygons(polygon.polygon, points)
	#
	#print(res)
	#
	#collision_polygon.set_deferred("polygon", res[0])
	#polygon.set_deferred("polygon", res[0])
	#area_collision_polygon.set_deferred("polygon", res[0])

func _on_area_2d_body_entered(body: Node2D) -> void:
	var id = body.get_instance_id()
	
	if body is Character and id != get_instance_id():
		_in_contact[id] = body
		print(_in_contact)

func _on_area_2d_body_exited(body: Node2D) -> void:
	var id = body.get_instance_id()
	
	if body is Character and _in_contact.has(id):
		_in_contact.erase(id)
		print(_in_contact)
