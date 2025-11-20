# elements/liquids/Water.gd
extends ElementBase

func _init():
	id = Constants.Elements.WATER
	element_name = "Water"
	color = Color(0.3, 0.5, 1.0)  # Brighter, clearer blue
	category = Constants.Category.LIQUIDS
	state = Constants.State.LIQUID
	
	density = 1.0
	
	is_movable = true

func update(x: int, y: int, grid: Grid) -> void:
	# PHASE 1: Fast falling with velocity
	if try_fall_fast(x, y, grid, 6.0):
		return
	
	# PHASE 2: Try diagonal falling
	var diagonals = [-1, 1]
	diagonals.shuffle()
	
	for dx in diagonals:
		if grid.is_valid(x + dx, y + 1) and grid.is_valid(x + dx, y):
			var diag_elem = grid.get_element(x + dx, y + 1)
			var side_elem = grid.get_element(x + dx, y)
			
			if diag_elem == Constants.Elements.EMPTY and side_elem == Constants.Elements.EMPTY:
				grid.move(x, y, x + dx, y + 1)
				return
	
	# PHASE 3: Horizontal dispersion (Sandspiel technique)
	# Try to spread up to 5 cells away in one frame
	var max_dispersion = 5
	
	# Check both directions
	var left_distance = check_horizontal_space(x, y, -1, max_dispersion, grid)
	var right_distance = check_horizontal_space(x, y, 1, max_dispersion, grid)
	
	if left_distance > 0 or right_distance > 0:
		# Move toward the direction with more space
		if left_distance > right_distance:
			# Move left
			grid.move(x, y, x - 1, y)
		elif right_distance > left_distance:
			# Move right
			grid.move(x, y, x + 1, y)
		else:
			# Equal - random choice
			if randf() < 0.5:
				grid.move(x, y, x - 1, y)
			else:
				grid.move(x, y, x + 1, y)

func check_horizontal_space(x: int, y: int, direction: int, max_dist: int, grid: Grid) -> int:
	# Count how many empty cells in this direction
	var empty_count = 0
	
	for dist in range(1, max_dist + 1):
		var check_x = x + (direction * dist)
		
		if not grid.is_valid(check_x, y):
			break
		
		var elem = grid.get_element(check_x, y)
		
		if elem == Constants.Elements.EMPTY:
			empty_count += 1
		elif elem != Constants.Elements.WATER:
			break  # Hit obstacle, stop counting
	
	return empty_count

func can_displace_element(element_id: int) -> bool:
	return element_id == Constants.Elements.OIL
