# elements/solids/Wood.gd
extends ElementBase

func _init():
	id = Constants.Elements.WOOD
	element_name = "Wood"
	color = Color(0.6, 0.3, 0.1)
	category = Constants.Category.SOLIDS
	state = Constants.State.SOLID
	
	density = 0.8
	flammability = 0.7
	heat_conductivity = 0.1
	
	is_movable = false
	is_flammable = true

func update(x: int, y: int, grid: Grid) -> void:
	# Wood is static - doesn't move
	# Just exists as a solid obstacle
	pass
