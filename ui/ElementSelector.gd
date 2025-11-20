# ui/ElementSelector.gd
extends OptionButton

var element_registry: ElementRegistry

func _ready():
	element_registry = get_node("/root/ElementRegistry")
	populate_elements()
	
	# Connect selection signal
	item_selected.connect(_on_element_selected)
	
	# Style the dropdown
	custom_minimum_size = Vector2(150, 35)

func populate_elements():
	# Clear existing items
	clear()
	
	# Add all registered elements
	var elements_to_add = [
		{"id": Constants.Elements.SAND, "name": "Sand"},
		{"id": Constants.Elements.WATER, "name": "Water"},
		{"id": Constants.Elements.LAVA, "name": "Lava"},
		{"id": Constants.Elements.STONE, "name": "Stone"},
		{"id": Constants.Elements.WOOD, "name": "Wood"},
		{"id": Constants.Elements.OIL, "name": "Oil"},
		{"id": Constants.Elements.FIRE, "name": "Fire"},
		{"id": Constants.Elements.STEAM, "name": "Steam"},
		{"id": Constants.Elements.SMOKE, "name": "Smoke"},
	]
	
	for elem in elements_to_add:
		add_item(elem["name"])
		set_item_metadata(get_item_count() - 1, elem["id"])
	
	# Set default to Sand
	selected = 0

func _on_element_selected(index: int):
	var element_id = get_item_metadata(index)
	var main = get_tree().root.get_node("Main")
	if main:
		main.current_element = element_id
