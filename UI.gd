# UI.gd - Simple UI overlay (most UI is now handled by Main.gd)
extends Control

func _ready():
	# Create simple instructions label
	create_instructions()

func create_instructions():
	# Instructions label - just basic controls now
	var instructions = Label.new()
	instructions.text = """CONTROLS:
Left Click: Place Element
2: Water (hotkey)
3: Lava (hotkey)
C: Clear Screen

Use dropdown to select elements"""
	instructions.position = Vector2(10, 10)
	instructions.add_theme_color_override("font_color", Color.WHITE)
	instructions.add_theme_color_override("font_shadow_color", Color.BLACK)
	instructions.add_theme_constant_override("shadow_offset_x", 1)
	instructions.add_theme_constant_override("shadow_offset_y", 1)
	add_child(instructions)
