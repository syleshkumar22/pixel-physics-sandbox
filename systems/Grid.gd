# systems/Grid.gd
# Manages the simulation grid and all cell data
class_name Grid
extends RefCounted

# Grid dimensions
var width: int
var height: int

# Main grid - stores element IDs
var cells: Array = []

# Secondary grids for additional properties
var temperature: Array = []
var pressure: Array = []
var updated: Array = []
var velocity_x: Array = []  # Horizontal velocity
var velocity_y: Array = []  # Vertical velocity (falling speed)


func _init(w: int = Constants.GRID_WIDTH, h: int = Constants.GRID_HEIGHT):
	width = w
	height = h
	initialize_grids()

func initialize_grids():
	cells = []
	temperature = []
	pressure = []
	updated = []
	velocity_x = []  # NEW
	velocity_y = []  # NEW
	
	for x in range(width):
		cells.append([])
		temperature.append([])
		pressure.append([])
		updated.append([])
		velocity_x.append([])  # NEW
		velocity_y.append([])  # NEW
		
		for y in range(height):
			cells[x].append(Constants.Elements.EMPTY)
			temperature[x].append(Constants.ROOM_TEMP)
			pressure[x].append(0.0)
			updated[x].append(false)
			velocity_x[x].append(0.0)  # NEW
			velocity_y[x].append(0.0)  # NEW

func clear():
	initialize_grids()

# === CORE ACCESS FUNCTIONS ===

func is_valid(x: int, y: int) -> bool:
	return x >= 0 and x < width and y >= 0 and y < height

func get_element(x: int, y: int) -> int:
	if not is_valid(x, y):
		return Constants.Elements.STONE
	return cells[x][y]

func set_element(x: int, y: int, element_id: int) -> void:
	if is_valid(x, y):
		cells[x][y] = element_id
		updated[x][y] = true

func get_temp(x: int, y: int) -> float:
	if not is_valid(x, y):
		return Constants.ROOM_TEMP
	return temperature[x][y]

func set_temp(x: int, y: int, temp: float) -> void:
	if is_valid(x, y):
		temperature[x][y] = temp

func is_empty(x: int, y: int) -> bool:
	return get_element(x, y) == Constants.Elements.EMPTY

func was_updated(x: int, y: int) -> bool:
	if not is_valid(x, y):
		return true
	return updated[x][y]

func mark_updated(x: int, y: int) -> void:
	if is_valid(x, y):
		updated[x][y] = true

func reset_updated_flags():
	for x in range(width):
		for y in range(height):
			updated[x][y] = false

# === MOVEMENT FUNCTIONS ===

func move(from_x: int, from_y: int, to_x: int, to_y: int) -> bool:
	if not is_valid(from_x, from_y) or not is_valid(to_x, to_y):
		return false
	
	if was_updated(from_x, from_y):
		return false
	
	var element = cells[from_x][from_y]
	var temp_val = temperature[from_x][from_y]
	
	cells[to_x][to_y] = element
	temperature[to_x][to_y] = temp_val
	
	cells[from_x][from_y] = Constants.Elements.EMPTY
	temperature[from_x][from_y] = Constants.ROOM_TEMP
	
	# Transfer velocity
	transfer_velocity(from_x, from_y, to_x, to_y)
	
	updated[to_x][to_y] = true
	updated[from_x][from_y] = true
	
	return true

func swap(x1: int, y1: int, x2: int, y2: int) -> bool:
	if not is_valid(x1, y1) or not is_valid(x2, y2):
		return false
	
	var temp_element = cells[x1][y1]
	var temp_temp = temperature[x1][y1]
	
	cells[x1][y1] = cells[x2][y2]
	temperature[x1][y1] = temperature[x2][y2]
	
	cells[x2][y2] = temp_element
	temperature[x2][y2] = temp_temp
	
	updated[x1][y1] = true
	updated[x2][y2] = true
	
	return true

# === NEIGHBOR QUERIES ===

func get_neighbors_4(x: int, y: int) -> Array:
	return [
		get_element(x - 1, y),
		get_element(x + 1, y),
		get_element(x, y - 1),
		get_element(x, y + 1)
	]

func get_neighbors_8(x: int, y: int) -> Array:
	return [
		get_element(x - 1, y - 1), get_element(x, y - 1), get_element(x + 1, y - 1),
		get_element(x - 1, y),                            get_element(x + 1, y),
		get_element(x - 1, y + 1), get_element(x, y + 1), get_element(x + 1, y + 1)
	]

func count_neighbors(x: int, y: int, element_id: int) -> int:
	var count = 0
	var neighbors = get_neighbors_8(x, y)
	for neighbor in neighbors:
		if neighbor == element_id:
			count += 1
	return count

# === AREA OPERATIONS ===

func fill_rect(x: int, y: int, w: int, h: int, element_id: int) -> void:
	for dx in range(w):
		for dy in range(h):
			set_element(x + dx, y + dy, element_id)

func fill_circle(center_x: int, center_y: int, radius: int, element_id: int) -> void:
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			if dx * dx + dy * dy <= radius * radius:
				set_element(center_x + dx, center_y + dy, element_id)
				
# === VELOCITY FUNCTIONS ===

func get_velocity(x: int, y: int) -> Vector2:
	if not is_valid(x, y):
		return Vector2.ZERO
	return Vector2(velocity_x[x][y], velocity_y[x][y])

func set_velocity(x: int, y: int, vel: Vector2) -> void:
	if is_valid(x, y):
		velocity_x[x][y] = vel.x
		velocity_y[x][y] = vel.y

func transfer_velocity(from_x: int, from_y: int, to_x: int, to_y: int) -> void:
	# Transfer velocity when element moves
	if is_valid(from_x, from_y) and is_valid(to_x, to_y):
		velocity_x[to_x][to_y] = velocity_x[from_x][from_y]
		velocity_y[to_x][to_y] = velocity_y[from_x][from_y]
		velocity_x[from_x][from_y] = 0.0
		velocity_y[from_x][from_y] = 0.0
