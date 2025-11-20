# elements/ElementBase.gd
# Base class for all elements - defines common interface
class_name ElementBase
extends RefCounted

# Element properties
var id: int = Constants.Elements.EMPTY
var element_name: String = "Unknown"
var color: Color = Color.BLACK
var category: Constants.Category = Constants.Category.SOLIDS
var state: Constants.State = Constants.State.SOLID

# Physical properties
var density: float = 1.0
var flammability: float = 0.0
var heat_conductivity: float = 0.1
var electrical_conductivity: float = 0.0
var melting_point: float = 1000.0
var boiling_point: float = 2000.0
var base_temperature: float = Constants.ROOM_TEMP

# Behavior flags
var is_movable: bool = true
var is_flammable: bool = false
var is_corrosive: bool = false
var is_explosive: bool = false
var is_conductive: bool = false

# === CORE UPDATE FUNCTION ===
func update(x: int, y: int, grid: Grid) -> void:
	pass

# === INTERACTION FUNCTION ===
func interact_with(other_id: int, x: int, y: int, neighbor_x: int, neighbor_y: int, grid: Grid) -> void:
	pass

# === HELPER FUNCTIONS ===

func try_fall(x: int, y: int, grid: Grid) -> bool:
	if grid.is_empty(x, y + 1):
		grid.move(x, y, x, y + 1)
		return true
	return false

func try_fall_diagonal(x: int, y: int, grid: Grid) -> bool:
	var dirs = [-1, 1]
	dirs.shuffle()
	
	for dir in dirs:
		var nx = x + dir
		var ny = y + 1
		if grid.is_empty(nx, ny) and grid.is_empty(x + dir, y):
			grid.move(x, y, nx, ny)
			return true
	
	return false

func try_spread_horizontal(x: int, y: int, grid: Grid) -> bool:
	var dirs = [-1, 1]
	dirs.shuffle()
	
	for dir in dirs:
		if grid.is_empty(x + dir, y):
			grid.move(x, y, x + dir, y)
			return true
	
	return false

func can_displace(other_id: int, grid: Grid) -> bool:
	if other_id == Constants.Elements.EMPTY:
		return true
	return false

func get_element_below(x: int, y: int, grid: Grid) -> int:
	return grid.get_element(x, y + 1)

func get_element_above(x: int, y: int, grid: Grid) -> int:
	return grid.get_element(x, y - 1)

func check_neighbors_for(x: int, y: int, element_id: int, grid: Grid) -> bool:
	var neighbors = grid.get_neighbors_4(x, y)
	return element_id in neighbors

func get_neighbor_positions(x: int, y: int) -> Array[Vector2i]:
	return [
		Vector2i(x - 1, y),
		Vector2i(x + 1, y),
		Vector2i(x, y - 1),
		Vector2i(x, y + 1)
	]
	
# === FAST FALLING WITH VELOCITY ===

func try_fall_fast(x: int, y: int, grid: Grid, max_speed: float = 5.0) -> bool:
	# Get current velocity
	var vel = grid.get_velocity(x, y)
	
	# Apply gravity (accelerate downward)
	vel.y += Constants.GRAVITY
	vel.y = min(vel.y, max_speed)  # Cap at terminal velocity
	
	# Calculate how many cells to try to fall
	var fall_distance = int(vel.y)
	fall_distance = max(1, fall_distance)  # At least try 1 cell
	
	# Try to fall multiple cells
	for distance in range(fall_distance, 0, -1):
		var target_y = y + distance
		
		if not grid.is_valid(x, target_y):
			continue
		
		var target_element = grid.get_element(x, target_y)
		
		if target_element == Constants.Elements.EMPTY:
			# Can fall this distance!
			grid.move(x, y, x, target_y)
			grid.set_velocity(x, target_y, vel)  # Keep velocity
			return true
		
		# Check if can displace
		elif can_displace_element(target_element):
			grid.swap(x, y, x, target_y)
			grid.set_velocity(x, target_y, vel)
			return true
	
	# Hit ground - reset velocity
	grid.set_velocity(x, y, Vector2.ZERO)
	return false

func can_displace_element(element_id: int) -> bool:
	# Override this in specific elements
	return false
