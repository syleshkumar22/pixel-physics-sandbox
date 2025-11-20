# systems/ElementRegistry.gd
extends Node

var element_classes: Dictionary = {}
var element_data: Dictionary = {}

func _ready():
	register_all_elements()

func register_all_elements():
	# Solids
	register_element(Constants.Elements.SAND, preload("res://elements/solids/Sand.gd"))
	register_element(Constants.Elements.STONE, preload("res://elements/solids/Stone.gd"))
	register_element(Constants.Elements.WOOD, preload("res://elements/solids/Wood.gd"))
	
	# Liquids
	register_element(Constants.Elements.WATER, preload("res://elements/liquids/Water.gd"))
	register_element(Constants.Elements.OIL, preload("res://elements/liquids/Oil.gd"))
	register_element(Constants.Elements.LAVA, preload("res://elements/liquids/Lava.gd"))
	
	# Gases
	register_element(Constants.Elements.STEAM, preload("res://elements/gases/Steam.gd"))
	register_element(Constants.Elements.SMOKE, preload("res://elements/gases/Smoke.gd"))
	
	# Energy
	register_element(Constants.Elements.FIRE, preload("res://elements/energy/Fire.gd"))
	register_element(Constants.Elements.OIL_FIRE, preload("res://elements/energy/OilFire.gd")) 

func register_element(id: int, element_script: Script):
	element_classes[id] = element_script
	
	var instance = element_script.new()
	element_data[id] = {
		"name": instance.element_name,
		"color": instance.color,
		"category": instance.category,
		"density": instance.density,
		"flammability": instance.flammability,
		"state": instance.state
	}

func create_element(id: int) -> ElementBase:
	if element_classes.has(id):
		return element_classes[id].new()
	return null

func get_element_color(id: int) -> Color:
	if element_data.has(id):
		return element_data[id]["color"]
	return Color.BLACK

func get_element_name(id: int) -> String:
	if element_data.has(id):
		return element_data[id]["name"]
	return "Unknown"

func get_element_category(id: int) -> Constants.Category:
	if element_data.has(id):
		return element_data[id]["category"]
	return Constants.Category.SOLIDS

func get_density(id: int) -> float:
	if element_data.has(id):
		return element_data[id]["density"]
	return 1.0
