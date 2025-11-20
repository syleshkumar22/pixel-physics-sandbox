# elements/gases/Steam.gd
extends ElementBase

func _init():
	id = Constants.Elements.STEAM
	element_name = "Steam"
	color = Color(0.9, 0.9, 0.9)
	category = Constants.Category.GASES
	state = Constants.State.GAS
	
	density = 0.0006
	flammability = 0.0
	heat_conductivity = 0.3
	base_temperature = 105.0
	
	is_movable = true
	is_flammable = false

func update(x: int, y: int, grid: Grid) -> void:
	# Steam rises slowly (30% chance per frame)
	if randf() > 0.3:
		return
	
	# Try to rise
	if grid.is_valid(x, y - 1):
		var above = grid.get_element(x, y - 1)
		if above == Constants.Elements.EMPTY:
			grid.move(x, y, x, y - 1)
			return
	
	# Spread sideways when blocked
	if randf() < 0.4:
		if randf() < 0.5:
			if not try_move_horizontal(x, y, 1, grid):
				try_move_horizontal(x, y, -1, grid)
		else:
			if not try_move_horizontal(x, y, -1, grid):
				try_move_horizontal(x, y, 1, grid)

func try_move_horizontal(x: int, y: int, direction: int, grid: Grid) -> bool:
	var target_x = x + direction
	var target_y = y
	
	if not grid.is_valid(target_x, target_y):
		return false
	
	if grid.get_element(target_x, target_y) == Constants.Elements.EMPTY:
		grid.move(x, y, target_x, target_y)
		return true
	
	return false
