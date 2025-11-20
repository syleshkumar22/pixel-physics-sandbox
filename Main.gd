# Main.gd
extends Node2D

var grid: Grid
var physics_engine: PhysicsEngine
var render_system: RenderSystem

var current_element: int = Constants.Elements.SAND
var brush_size: int = 3
var is_painting: bool = false

var ui_layer: CanvasLayer
var dropdown: Control

func _ready():
	# Initialize core systems
	grid = Grid.new()
	physics_engine = PhysicsEngine.new(grid)
	render_system = RenderSystem.new(grid)
	
	add_child(physics_engine)
	add_child(render_system)
	
	# Setup window
	get_window().size = Vector2i(800, 600)
	get_window().min_size = Vector2i(400, 300)
	
	# Connect resize signal
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	# Create UI
	create_ui()
	
	# Initial render
	render_system.render()

func _process(_delta):
	# Update physics
	physics_engine.update_simulation()
	
	# Render
	render_system.render()

func _input(event):
	handle_mouse_input(event)
	handle_keyboard_input(event)

func handle_mouse_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Check if mouse is over UI
			if is_mouse_over_ui():
				is_painting = false
				return
			
			is_painting = event.pressed
			if event.pressed:
				place_element_at_mouse()
	
	elif event is InputEventMouseMotion:
		if is_painting:
			# Check if mouse is over UI
			if is_mouse_over_ui():
				is_painting = false
				return
			
			place_element_at_mouse()

func is_mouse_over_ui() -> bool:
	# Check if mouse is hovering over dropdown
	if dropdown:
		var mouse_pos = dropdown.get_global_mouse_position()
		var dropdown_rect = Rect2(dropdown.global_position, dropdown.size)
		return dropdown_rect.has_point(mouse_pos)
	return false

func handle_keyboard_input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_C:
				grid.clear()
			KEY_1:
				current_element = Constants.Elements.SAND
				update_dropdown_selection()
			KEY_2:
				current_element = Constants.Elements.WATER
				update_dropdown_selection()
			KEY_3:
				current_element = Constants.Elements.LAVA
				update_dropdown_selection()
			KEY_MINUS:
				brush_size = max(1, brush_size - 1)
			KEY_EQUAL, KEY_PLUS:
				brush_size = min(10, brush_size + 1)

func update_dropdown_selection():
	# Update dropdown to match keyboard selection
	if dropdown and dropdown is OptionButton:
		for i in range(dropdown.get_item_count()):
			if dropdown.get_item_metadata(i) == current_element:
				dropdown.selected = i
				break

func place_element_at_mouse():
	var mouse_pos = get_global_mouse_position()
	var grid_x = int(mouse_pos.x / render_system.cell_size)
	var grid_y = int(mouse_pos.y / render_system.cell_size)
	
	grid.fill_circle(grid_x, grid_y, brush_size, current_element)

func _on_viewport_resized():
	render_system.update_sprite_transform()
	if dropdown:
		dropdown.position = Vector2(get_viewport().size.x - 170, 20)

func create_ui():
	# Create CanvasLayer for UI
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	# Create dropdown
	var dropdown_script = preload("res://ui/ElementSelector.gd")
	dropdown = OptionButton.new()
	dropdown.set_script(dropdown_script)
	dropdown.position = Vector2(get_viewport().size.x - 170, 20)
	dropdown.custom_minimum_size = Vector2(150, 35)
	dropdown.mouse_filter = Control.MOUSE_FILTER_STOP  # Block mouse from passing through
	ui_layer.add_child(dropdown)
