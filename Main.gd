# Main.gd - Attach this to your main scene node
extends Node2D

# Grid settings
const GRID_WIDTH = 200
const GRID_HEIGHT = 150
const CELL_SIZE = 4

# Element types
enum Element {
	EMPTY,
	SAND,
	WATER,
	LAVA,
	STONE,
	FIRE
}

# Element colors
var element_colors = {
	Element.EMPTY: Color.BLACK,
	Element.SAND: Color.YELLOW,
	Element.WATER: Color.BLUE,
	Element.LAVA: Color.ORANGE,
	Element.STONE: Color.GRAY,
	Element.FIRE: Color.RED
}

# The main grid - stores element types
var grid = []
var current_element = Element.SAND
var brush_size = 3

# For rendering
var texture: ImageTexture
var image: Image

func _ready():
	# Initialize the grid
	initialize_grid()
	
	# Create the image for rendering
	image = Image.create(GRID_WIDTH, GRID_HEIGHT, false, Image.FORMAT_RGB8)
	texture = ImageTexture.create_from_image(image)
	
	# Create a sprite to display our simulation
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.scale = Vector2(CELL_SIZE, CELL_SIZE)
	sprite.position = Vector2(GRID_WIDTH * CELL_SIZE / 2, GRID_HEIGHT * CELL_SIZE / 2)
	add_child(sprite)
	
	# Set up the window
	get_window().size = Vector2i(GRID_WIDTH * CELL_SIZE, GRID_HEIGHT * CELL_SIZE + 100)

func initialize_grid():
	grid = []
	for x in range(GRID_WIDTH):
		grid.append([])
		for y in range(GRID_HEIGHT):
			grid[x].append(Element.EMPTY)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			var mouse_pos = get_global_mouse_position()
			var grid_x = int(mouse_pos.x / CELL_SIZE)
			var grid_y = int(mouse_pos.y / CELL_SIZE)
			
			if event.button_index == MOUSE_BUTTON_LEFT:
				place_element(grid_x, grid_y, current_element)
			# Right click does nothing now
	
	elif event is InputEventMouseMotion:
		# Allow painting while dragging with left mouse only
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var mouse_pos = get_global_mouse_position()
			var grid_x = int(mouse_pos.x / CELL_SIZE)
			var grid_y = int(mouse_pos.y / CELL_SIZE)
			place_element(grid_x, grid_y, current_element)
	
	# Element selection keys
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_2:
				current_element = Element.WATER
			KEY_3:
				current_element = Element.LAVA
			KEY_C:
				initialize_grid()  # Clear screen

func place_element(x: int, y: int, element: Element):
	# Place element in a brush pattern
	for dx in range(-brush_size/2, brush_size/2 + 1):
		for dy in range(-brush_size/2, brush_size/2 + 1):
			var nx = x + dx
			var ny = y + dy
			if is_valid_position(nx, ny):
				grid[nx][ny] = element

func is_valid_position(x: int, y: int) -> bool:
	return x >= 0 and x < GRID_WIDTH and y >= 0 and y < GRID_HEIGHT

func get_element(x: int, y: int) -> Element:
	if not is_valid_position(x, y):
		return Element.STONE  # Treat out of bounds as solid
	return grid[x][y]

func set_element(x: int, y: int, element: Element):
	if is_valid_position(x, y):
		grid[x][y] = element

func _process(_delta):
	# Update physics simulation
	update_physics()
	
	# Render the grid
	render_grid()

func update_physics():
	# Process from bottom-up, right-to-left to avoid double processing
	for y in range(GRID_HEIGHT - 2, -1, -1):
		for x in range(GRID_WIDTH - 1, -1, -1):
			var element = grid[x][y]
			
			match element:
				Element.SAND:
					update_sand(x, y)
				Element.WATER:
					update_water(x, y)
				Element.LAVA:
					update_lava(x, y)
				Element.FIRE:
					update_fire(x, y)

func update_sand(x: int, y: int):
	# Sand falls down
	if get_element(x, y + 1) == Element.EMPTY:
		set_element(x, y, Element.EMPTY)
		set_element(x, y + 1, Element.SAND)
	# Sand spreads sideways when blocked
	elif get_element(x, y + 1) in [Element.WATER, Element.LAVA]:
		# Sand can fall through liquids (displaces them)
		var liquid = get_element(x, y + 1)
		set_element(x, y, liquid)
		set_element(x, y + 1, Element.SAND)
	else:
		# Try to slide sideways
		var directions = [-1, 1]
		directions.shuffle()
		for dir in directions:
			if get_element(x + dir, y + 1) == Element.EMPTY and get_element(x + dir, y) == Element.EMPTY:
				set_element(x, y, Element.EMPTY)
				set_element(x + dir, y + 1, Element.SAND)
				break

func update_water(x: int, y: int):
	# Water falls down
	if get_element(x, y + 1) == Element.EMPTY:
		set_element(x, y, Element.EMPTY)
		set_element(x, y + 1, Element.WATER)
	else:
		# Water spreads sideways
		var directions = [-1, 1]
		directions.shuffle()
		for dir in directions:
			if get_element(x + dir, y) == Element.EMPTY:
				set_element(x, y, Element.EMPTY)
				set_element(x + dir, y, Element.WATER)
				break
	
	# Water + Lava = Stone
	check_lava_interaction(x, y)

func update_lava(x: int, y: int):
	# Lava falls slowly (random chance)
	if randf() < 0.3:  # 30% chance to fall each frame
		if get_element(x, y + 1) == Element.EMPTY:
			set_element(x, y, Element.EMPTY)
			set_element(x, y + 1, Element.LAVA)
	
	# Check for water interaction
	check_water_interaction(x, y)

func update_fire(x: int, y: int):
	# Fire burns out after some time (random)
	if randf() < 0.02:  # 2% chance to extinguish each frame
		set_element(x, y, Element.EMPTY)
		return
	
	# Fire spreads to nearby flammable materials
	var directions = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for dir in directions:
		var nx = x + dir.x
		var ny = y + dir.y
		if get_element(nx, ny) == Element.WATER:
			# Water extinguishes fire
			set_element(x, y, Element.EMPTY)
			return

func check_lava_interaction(x: int, y: int):
	var directions = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for dir in directions:
		var nx = x + dir.x
		var ny = y + dir.y
		if get_element(nx, ny) == Element.LAVA:
			set_element(x, y, Element.STONE)
			set_element(nx, ny, Element.STONE)
			return

func check_water_interaction(x: int, y: int):
	var directions = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for dir in directions:
		var nx = x + dir.x
		var ny = y + dir.y
		if get_element(nx, ny) == Element.WATER:
			set_element(x, y, Element.STONE)
			return

func render_grid():
	# Update the image with current grid state
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var element = grid[x][y]
			var color = element_colors[element]
			image.set_pixel(x, y, color)
	
	# Update the texture
	texture.update(image)
