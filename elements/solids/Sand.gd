# elements/solids/Sand.gd
extends ElementBase

func _init():
	id = Constants.Elements.SAND
	element_name = "Sand"
	color = Color(0.93, 0.87, 0.51)
	category = Constants.Category.SOLIDS
	state = Constants.State.POWDER
	
	density = 1.5
	flammability = 0.0
	heat_conductivity = 0.2
	base_temperature = Constants.ROOM_TEMP
	
	is_movable = true
	is_flammable = false

func update(x: int, y: int, grid: Grid) -> void:
	# Try fast falling with velocity
	if try_fall_fast(x, y, grid, 8.0):  # Max speed: 8 cells/frame
		return
	
	# If can't fall straight, try diagonal
	if try_fall_diagonal(x, y, grid):
		return

func can_displace_element(element_id: int) -> bool:
	# Sand sinks through liquids
	return element_id == Constants.Elements.WATER or element_id == Constants.Elements.OIL
