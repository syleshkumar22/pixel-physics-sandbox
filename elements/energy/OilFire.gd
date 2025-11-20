# elements/energy/OilFire.gd
extends ElementBase

func _init():
	id = Constants.Elements.OIL_FIRE
	element_name = "Oil Fire"
	color = Color(1.0, 0.5, 0.0)  # Orange-yellow (hotter looking)
	category = Constants.Category.ENERGY
	state = Constants.State.ENERGY
	
	density = 0.0
	base_temperature = 800.0  # Hotter than regular fire
	
	is_movable = false
	is_flammable = false

func update(x: int, y: int, grid: Grid) -> void:
	# Oil fire burns out VERY quickly (consumes fuel fast)
	if randf() < 0.15:  # 15% chance = burns out in ~0.5 seconds
		grid.set_element(x, y, Constants.Elements.EMPTY)
		return
	
	# Spread to nearby oil VERY fast (explosive spread)
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
			
			# Spread to oil INSTANTLY (90% chance)
			elif neighbor == Constants.Elements.OIL and randf() < 0.9:
				grid.set_element(nx, ny, Constants.Elements.OIL_FIRE)
			
			# Also spread to wood
			elif neighbor == Constants.Elements.WOOD and randf() < 0.3:
				grid.set_element(nx, ny, Constants.Elements.FIRE)
