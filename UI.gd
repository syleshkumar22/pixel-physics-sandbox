# UI.gd - Attach this to a Control node or CanvasLayer
extends Control

var main_scene: Node2D
var element_names = {
	0: "Empty",
	1: "Sand", 
	2: "Water",
	3: "Lava",
	4: "Stone",
	5: "Fire"
}

func _ready():
	# Find the main scene
	main_scene = get_node("../Main")  # Adjust path as needed
	
	# Create UI elements
	create_ui()

func create_ui():
	# Instructions label
	var instructions = Label.new()
	instructions.text = """CONTROLS:
Left Click: Place Element
2: Water
3: Lava
C: Clear Screen

Current: Sand"""
	instructions.position = Vector2(10, 10)
	instructions.add_theme_color_override("font_color", Color.WHITE)
	instructions.add_theme_color_override("font_shadow_color", Color.BLACK)
	instructions.add_theme_constant_override("shadow_offset_x", 1)
	instructions.add_theme_constant_override("shadow_offset_y", 1)
	add_child(instructions)

func _process(_delta):
	if main_scene and has_node("Label"):
		var label = get_node("Label")
		var current_element_name = element_names.get(main_scene.current_element, "Unknown")
		var text_lines = label.text.split("\n")
		text_lines[-1] = "Current: " + current_element_name
		label.text = "\n".join(text_lines)
