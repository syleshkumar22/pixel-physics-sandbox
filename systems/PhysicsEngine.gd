# systems/PhysicsEngine.gd
class_name PhysicsEngine
extends Node

var grid: Grid
var element_registry: ElementRegistry

func _init(grid_instance: Grid):
	grid = grid_instance

func _ready():
	element_registry = get_node("/root/ElementRegistry")

func update_simulation():
	# Reset updated flags
	grid.reset_updated_flags()
	
	# Process from bottom-up, right-to-left
	# BUT: Skip large chunks of empty space
	for y in range(grid.height - 2, -1, -1):
		# Early exit if entire row is empty
		var has_content = false
		for x in range(grid.width):
			if grid.get_element(x, y) != Constants.Elements.EMPTY:
				has_content = true
				break
		
		if not has_content:
			continue  # Skip entire empty row
		
		# Process this row
		for x in range(grid.width - 1, -1, -1):
			var element_id = grid.get_element(x, y)
			
			if element_id == Constants.Elements.EMPTY:
				continue
			
			if grid.was_updated(x, y):
				continue
			
			# Check if element can possibly move
			# Skip if surrounded by solid elements (settled)
			var below = grid.get_element(x, y + 1)
			if below != Constants.Elements.EMPTY and below != Constants.Elements.WATER and below != Constants.Elements.OIL:
				# Check if can move sideways
				var left = grid.get_element(x - 1, y)
				var right = grid.get_element(x + 1, y)
				if left != Constants.Elements.EMPTY and right != Constants.Elements.EMPTY:
					continue  # Completely settled, skip
			
			# Get element instance and update it
			var element = element_registry.create_element(element_id)
			if element:
				element.update(x, y, grid)
