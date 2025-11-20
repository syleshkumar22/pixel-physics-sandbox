# elements/liquids/Oil.gd
extends ElementBase

func _init():
	id = Constants.Elements.OIL
	element_name = "Oil"
	color = Color(0.2, 0.1, 0.3)
	category = Constants.Category.LIQUIDS
	state = Constants.State.LIQUID
	
	density = 0.8
	flammability = 0.9
	
	is_movable = true
	is_flammable = true

func update(x: int, y: int, grid: Grid) -> void:
	# Check for fire/lava FIRST before moving
	check_ignition(x, y, grid)
	
	# Fast falling like water
	if try_fall_fast(x, y, grid, 5.0):
		return
	
	# Try diagonal
	var fall_directions = [-1, 1]
	fall_directions.shuffle()
	
	for offset in fall_directions:
		var target_x = x + offset
		var target_y = y + 1
		
		if not grid.is_valid(target_x, target_y):
			continue
		
		if grid.get_element(target_x, target_y) == Constants.Elements.EMPTY:
			if grid.is_empty(x + offset, y):
				grid.move(x, y, target_x, target_y)
				return
	
	# Spread horizontally (2 cells at once)
	var spread_distance = 2
	
	if randf() < 0.5:
		for dist in range(1, spread_distance + 1):
			if try_spread_to(x, y, dist, grid):
				return
		for dist in range(1, spread_distance + 1):
			if try_spread_to(x, y, -dist, grid):
				return
	else:
		for dist in range(1, spread_distance + 1):
			if try_spread_to(x, y, -dist, grid):
				return
		for dist in range(1, spread_distance + 1):
			if try_spread_to(x, y, dist, grid):
				return

func check_ignition(x: int, y: int, grid: Grid) -> void:
	# Check all 8 neighbors for fire or lava
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			
			var nx = x + dx
			var ny = y + dy
			
			if not grid.is_valid(nx, ny):
				continue
			
			var neighbor = grid.get_element(nx, ny)
			
			# Oil ignites into OIL_FIRE (fast burning)
			if neighbor == Constants.Elements.FIRE and randf() < 0.8:
				grid.set_element(x, y, Constants.Elements.OIL_FIRE)  # Changed from FIRE
				return
			
			# Oil ignites from lava into OIL_FIRE
			elif neighbor == Constants.Elements.LAVA and randf() < 0.6:
				grid.set_element(x, y, Constants.Elements.OIL_FIRE)  # Changed from FIRE
				return
	# Check all 8 neighbors for fire or lava
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			
			var nx = x + dx
			var ny = y + dy
			
			if not grid.is_valid(nx, ny):
				continue
			
			var neighbor = grid.get_element(nx, ny)
			
			# Oil ignites from fire (80% chance)
			if neighbor == Constants.Elements.FIRE and randf() < 0.8:
				grid.set_element(x, y, Constants.Elements.FIRE)
				return
			
			# Oil ignites from lava (60% chance)
			elif neighbor == Constants.Elements.LAVA and randf() < 0.6:
				grid.set_element(x, y, Constants.Elements.FIRE)
				return

func try_spread_to(x: int, y: int, distance: int, grid: Grid) -> bool:
	var target_x = x + distance
	
	if not grid.is_valid(target_x, y):
		return false
	
	var sign_dir = 1 if distance > 0 else -1
	for check_x in range(x + sign_dir, target_x + sign_dir, sign_dir):
		var elem = grid.get_element(check_x, y)
		if elem != Constants.Elements.EMPTY and elem != Constants.Elements.OIL:
			return false
	
	if grid.get_element(target_x, y) == Constants.Elements.EMPTY:
		grid.move(x, y, target_x, y)
		return true
	
	return false
