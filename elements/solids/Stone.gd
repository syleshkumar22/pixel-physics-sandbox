# elements/solids/Stone.gd
extends ElementBase

func _init():
	id = Constants.Elements.STONE
	element_name = "Stone"
	color = Color(0.5, 0.5, 0.5)
	category = Constants.Category.SOLIDS
	state = Constants.State.SOLID
	
	density = 3.0
	flammability = 0.0
	heat_conductivity = 0.3
	melting_point = 1500.0
	
	is_movable = false
	is_flammable = false

func update(x: int, y: int, grid: Grid) -> void:
	# Stone is static - no movement
	pass
