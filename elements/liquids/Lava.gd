# elements/liquids/Lava.gd
extends ElementBase

func _init():
	id = Constants.Elements.LAVA
	element_name = "Lava"
	color = Color(1.0, 0.3, 0.0)
	category = Constants.Category.LIQUIDS
	state = Constants.State.LIQUID
	
	density = 2.5
	flammability = 0.0
	base_temperature = 1200.0
	
	is_movable = true
	is_flammable = false

func update(x: int, y: int, grid: Grid) -> void:
	# Lava is viscous - moves 60% of the time
	if randf() > 0.6:
		return
	
	# Check for water interaction FIRST
	if check_water_nearby(x, y, grid):
		return
	
	# Ignite nearby oil
	check_oil_ignition(x, y, grid)
	
	# Fall with velocity (but slower than water)
	if try_fall_fast(x, y, grid, 3.0):  # Max 3 cells/frame
		return
	
	# Try diagonal
	var fall_directions = [-1, 1]
	fall_directions.shuffle()
	
	for offset in fall_directions:
		var target_x = x + offset
		var target_y = y + 1
		
		if not grid.is_valid(target_x, target_y):
			continue
		
		var target_element = grid.get_element(target_x, target_y)
		
		if target_element == Constants.Elements.EMPTY:
			if grid.is_empty(x + offset, y):
				grid.move(x, y, target_x, target_y)
				return
		elif target_element == Constants.Elements.WATER:
			grid.set_element(x, y, Constants.Elements.STONE)
			grid.set_element(target_x, target_y, Constants.Elements.STONE)
			return
	
	# Spread horizontally slowly
	if randf() < 0.5:
		try_spread_horizontal(x, y, grid)

func check_water_nearby(x: int, y: int, grid: Grid) -> bool:
	# Check all neighbors for water
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			
			var nx = x + dx
			var ny = y + dy
			
			if not grid.is_valid(nx, ny):
				continue
			
			if grid.get_element(nx, ny) == Constants.Elements.WATER:
				# Turn both to stone
				grid.set_element(x, y, Constants.Elements.STONE)
				grid.set_element(nx, ny, Constants.Elements.STONE)
				return true
	
	return false

func check_oil_ignition(x: int, y: int, grid: Grid) -> void:
	# Check neighbors for flammable materials (oil and wood) and ignite them
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			
			var nx = x + dx
			var ny = y + dy
			
			if not grid.is_valid(nx, ny):
				continue
			
			var neighbor = grid.get_element(nx, ny)
			
			# Ignite oil with OIL_FIRE (50% chance)
			if neighbor == Constants.Elements.OIL and randf() < 0.5:
				grid.set_element(nx, ny, Constants.Elements.OIL_FIRE)  # Changed from FIRE
			
			# Ignite wood with regular fire (30% chance)
			elif neighbor == Constants.Elements.WOOD and randf() < 0.3:
				grid.set_element(nx, ny, Constants.Elements.FIRE)
	# Check neighbors for flammable materials (oil and wood) and ignite them
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			
			var nx = x + dx
			var ny = y + dy
			
			if not grid.is_valid(nx, ny):
				continue
			
			var neighbor = grid.get_element(nx, ny)
			
			# Ignite oil (50% chance)
			if neighbor == Constants.Elements.OIL and randf() < 0.5:
				grid.set_element(nx, ny, Constants.Elements.FIRE)
			
			# Ignite wood (30% chance - slightly slower than oil)
			elif neighbor == Constants.Elements.WOOD and randf() < 0.3:
				grid.set_element(nx, ny, Constants.Elements.FIRE)

func can_displace_element(element_id: int) -> bool:
	return element_id == Constants.Elements.WATER or element_id == Constants.Elements.OIL
