# elements/energy/Fire.gd
extends ElementBase

func _init():
	id = Constants.Elements.FIRE
	element_name = "Fire"
	color = Color(1.0, 0.3, 0.0)
	category = Constants.Category.ENERGY
	state = Constants.State.ENERGY
	
	density = 0.0
	base_temperature = 600.0
	
	is_movable = false
	is_flammable = false

func update(x: int, y: int, grid: Grid) -> void:
	# Fire burns out quickly
	if randf() < 0.02:  # 2% chance (lasts ~1 second)
		grid.set_element(x, y, Constants.Elements.EMPTY)
		return
	
	# Fast spreading - check all 8 neighbors
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			
			var nx = x + dx
			var ny = y + dy
			
			if not grid.is_valid(nx, ny):
				continue
			
			var neighbor = grid.get_element(nx, ny)
			
			# Water extinguishes
			if neighbor == Constants.Elements.WATER:
				grid.set_element(x, y, Constants.Elements.STEAM)
				grid.set_element(nx, ny, Constants.Elements.STEAM)
				return
			
			# Spread to oil FAST
			elif neighbor == Constants.Elements.OIL and randf() < 0.6:  # 60% chance
				grid.set_element(nx, ny, Constants.Elements.OIL_FIRE)
			
			# Spread to wood
			elif neighbor == Constants.Elements.WOOD and randf() < 0.2:  # 20% chance
				grid.set_element(nx, ny, Constants.Elements.FIRE)
