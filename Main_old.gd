# Main.gd - Attach this to your main scene node
extends Node2D

# Grid settings
const GRID_WIDTH = 200
const GRID_HEIGHT = 150
var cell_size = 4
var viewport_size: Vector2

# Element types
enum Element {
	EMPTY,
	SAND,
	WATER,
	LAVA,
	STONE,
	FIRE,
	WOOD,
	OIL,
	STEAM,
	SMOKE,
	CHARCOAL  # Burned wood state
}

# Element colors
var element_colors = {
	Element.EMPTY: Color.BLACK,
	Element.SAND: Color.YELLOW,
	Element.WATER: Color.BLUE,
	Element.LAVA: Color.ORANGE,
	Element.STONE: Color.GRAY,
	Element.FIRE: Color.RED,
	Element.WOOD: Color(0.6, 0.3, 0.1),  # Brown
	Element.OIL: Color(0.2, 0.1, 0.3),   # Dark purple
	Element.STEAM: Color(0.9, 0.9, 0.9), # Light gray
	Element.SMOKE: Color(0.3, 0.3, 0.3), # Dark gray
	Element.CHARCOAL: Color(0.1, 0.1, 0.1) # Very dark gray/black
}

var element_names = {
	Element.SAND: "Sand",
	Element.WATER: "Water", 
	Element.LAVA: "Lava",
	Element.WOOD: "Wood",
	Element.OIL: "Oil",
	Element.STEAM: "Steam"
}

# The main grid - stores element types
var grid = []
var current_element = Element.SAND
var brush_size = 3

# Track water dispersion range for smooth spreading
var water_dispersion_rate = 5  # How many cells water tries to spread per frame

# For rendering
var texture: ImageTexture
var image: Image

# UI elements
var dropdown: OptionButton

func _ready():
	# Initialize the grid
	initialize_grid()
	
	# Get viewport size and calculate appropriate cell size
	viewport_size = get_viewport().get_visible_rect().size
	
	# Calculate cell size to fit the screen nicely
	var width_ratio = viewport_size.x / GRID_WIDTH
	var height_ratio = viewport_size.y / GRID_HEIGHT
	cell_size = min(width_ratio, height_ratio)
	cell_size = max(cell_size, 2)  # Minimum cell size of 2 pixels
	
	# Create the image for rendering
	image = Image.create(GRID_WIDTH, GRID_HEIGHT, false, Image.FORMAT_RGB8)
	texture = ImageTexture.create_from_image(image)
	
	# Create a sprite to display our simulation
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.scale = Vector2(cell_size, cell_size)
	sprite.position = Vector2(GRID_WIDTH * cell_size / 2, GRID_HEIGHT * cell_size / 2)
	add_child(sprite)
	
	# Make window resizable
	get_window().size = Vector2i(800, 600)  # Default size
	get_window().min_size = Vector2i(400, 300)  # Minimum size
	
	# Connect to window resize signal
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	# Create UI dropdown
	create_element_dropdown()

func initialize_grid():
	grid = []
	for x in range(GRID_WIDTH):
		grid.append([])
		for y in range(GRID_HEIGHT):
			grid[x].append(Element.EMPTY)

func create_element_dropdown():
	# Create a CanvasLayer for UI
	var ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	# Create dropdown button
	dropdown = OptionButton.new()
	dropdown.size = Vector2(120, 30)
	dropdown.position = Vector2(get_viewport().size.x - 140, 20)
	
	# Add element options
	for element in element_names.keys():
		dropdown.add_item(element_names[element])
		dropdown.set_item_metadata(dropdown.get_item_count() - 1, element)
	
	# Set default to Sand (first item)
	dropdown.selected = 0
	current_element = Element.SAND
	
	# Connect selection signal
	dropdown.item_selected.connect(_on_element_selected)
	
	# Style the dropdown
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.9)
	style.border_color = Color.WHITE
	style.border_width_left = 1
	style.border_width_right = 1  
	style.border_width_top = 1
	style.border_width_bottom = 1
	dropdown.add_theme_stylebox_override("normal", style)
	dropdown.add_theme_color_override("font_color", Color.WHITE)
	
	ui_layer.add_child(dropdown)

func _on_element_selected(index: int):
	current_element = dropdown.get_item_metadata(index)

func _on_viewport_size_changed():
	# Recalculate cell size when window is resized
	viewport_size = get_viewport().get_visible_rect().size
	var width_ratio = viewport_size.x / GRID_WIDTH
	var height_ratio = viewport_size.y / GRID_HEIGHT
	cell_size = min(width_ratio, height_ratio)
	cell_size = max(cell_size, 2)  # Minimum cell size of 2 pixels
	
	# Update sprite scale and position
	if has_node("Sprite2D"):
		var sprite = get_node("Sprite2D")
		sprite.scale = Vector2(cell_size, cell_size)
		sprite.position = Vector2(GRID_WIDTH * cell_size / 2, GRID_HEIGHT * cell_size / 2)
	
	# Update dropdown position
	if dropdown:
		dropdown.position = Vector2(get_viewport().size.x - 140, 20)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			var mouse_pos = get_global_mouse_position()
			var grid_x = int(mouse_pos.x / cell_size)
			var grid_y = int(mouse_pos.y / cell_size)
			
			if event.button_index == MOUSE_BUTTON_LEFT:
				place_element(grid_x, grid_y, current_element)
			# Right click does nothing now
	
	elif event is InputEventMouseMotion:
		# Allow painting while dragging with left mouse only
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var mouse_pos = get_global_mouse_position()
			var grid_x = int(mouse_pos.x / cell_size)
			var grid_y = int(mouse_pos.y / cell_size)
			place_element(grid_x, grid_y, current_element)
	
	# Element selection keys (still work as backup)
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_2:
				current_element = Element.WATER
				update_dropdown_selection()
			KEY_3:
				current_element = Element.LAVA
				update_dropdown_selection()
			KEY_C:
				initialize_grid()  # Clear screen

func update_dropdown_selection():
	# Update dropdown to match current element
	if dropdown:
		for i in range(dropdown.get_item_count()):
			if dropdown.get_item_metadata(i) == current_element:
				dropdown.selected = i
				break

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
				Element.WOOD:
					update_wood(x, y)
				Element.OIL:
					update_oil(x, y)
				Element.STEAM:
					update_steam(x, y)
				Element.SMOKE:
					update_smoke(x, y)
				Element.CHARCOAL:
					update_charcoal(x, y)

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
	# Check interactions first
	check_lava_interaction(x, y)
	check_fire_interaction(x, y)
	
	# Step 1: Always try to fall down first (gravity)
	var below = get_element(x, y + 1)
	if below == Element.EMPTY:
		set_element(x, y, Element.EMPTY)
		set_element(x, y + 1, Element.WATER)
		return
	
	# Can displace oil (water is denser)
	if below == Element.OIL:
		set_element(x, y, Element.OIL)
		set_element(x, y + 1, Element.WATER)
		return
	
	# Step 2: Try diagonal falling (creates smoother cascade)
	var diag_left = get_element(x - 1, y + 1)
	var diag_right = get_element(x + 1, y + 1)
	var side_left = get_element(x - 1, y)
	var side_right = get_element(x + 1, y)
	
	# Randomly try left or right diagonal first
	if randf() < 0.5:
		# Try left diagonal
		if diag_left == Element.EMPTY and side_left == Element.EMPTY:
			set_element(x, y, Element.EMPTY)
			set_element(x - 1, y + 1, Element.WATER)
			return
		# Try right diagonal
		if diag_right == Element.EMPTY and side_right == Element.EMPTY:
			set_element(x, y, Element.EMPTY)
			set_element(x + 1, y + 1, Element.WATER)
			return
	else:
		# Try right diagonal first
		if diag_right == Element.EMPTY and side_right == Element.EMPTY:
			set_element(x, y, Element.EMPTY)
			set_element(x + 1, y + 1, Element.WATER)
			return
		# Try left diagonal
		if diag_left == Element.EMPTY and side_left == Element.EMPTY:
			set_element(x, y, Element.EMPTY)
			set_element(x - 1, y + 1, Element.WATER)
			return
	
	# Step 3: Spread horizontally - simple and reliable
	var left = get_element(x - 1, y)
	var right = get_element(x + 1, y)
	
	var left_empty = (left == Element.EMPTY)
	var right_empty = (right == Element.EMPTY)
	
	# If both sides are open, alternate randomly for smooth spread
	if left_empty and right_empty:
		if randf() < 0.5:
			set_element(x, y, Element.EMPTY)
			set_element(x - 1, y, Element.WATER)
		else:
			set_element(x, y, Element.EMPTY)
			set_element(x + 1, y, Element.WATER)
		return
	
	# If only left is open, move left
	if left_empty:
		set_element(x, y, Element.EMPTY)
		set_element(x - 1, y, Element.WATER)
		return
	
	# If only right is open, move right
	if right_empty:
		set_element(x, y, Element.EMPTY)
		set_element(x + 1, y, Element.WATER)
		return
	
	# If all directions blocked, water stays in place

func update_lava(x: int, y: int):
	# Lava behaves like thick liquid - slower movement
	var move_chance = 0.4  # 40% chance to move (thicker than water)
	
	if randf() < move_chance:
		# Try to fall first (like liquid)
		if get_element(x, y + 1) == Element.EMPTY:
			set_element(x, y, Element.EMPTY)
			set_element(x, y + 1, Element.LAVA)
		# Can displace lighter liquids
		elif get_element(x, y + 1) == Element.WATER:
			set_element(x, y, Element.WATER)
			set_element(x, y + 1, Element.LAVA)
		elif get_element(x, y + 1) == Element.OIL:
			set_element(x, y, Element.OIL)
			set_element(x, y + 1, Element.LAVA)
		else:
			# Spread sideways like thick liquid
			var directions = [-1, 1]
			directions.shuffle()
			for dir in directions:
				if get_element(x + dir, y) == Element.EMPTY and randf() < 0.6:
					set_element(x, y, Element.EMPTY)
					set_element(x + dir, y, Element.LAVA)
					break
				elif get_element(x + dir, y) == Element.WATER and randf() < 0.8:
					set_element(x, y, Element.WATER)
					set_element(x + dir, y, Element.LAVA)
					break
	
	# Check for interactions with flammable materials
	check_lava_fire_interactions(x, y)
	# Check for water interaction (stone formation)
	check_water_interaction(x, y)

func check_lava_fire_interactions(x: int, y: int):
	var directions = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for dir in directions:
		var nx = x + dir.x
		var ny = y + dir.y
		var nearby = get_element(nx, ny)
		
		if nearby == Element.WOOD and randf() < 0.1:  # Slower wood charring from lava
			set_element(nx, ny, Element.CHARCOAL)
		elif nearby == Element.CHARCOAL and randf() < 0.2:  # Charcoal can ignite from lava
			set_element(nx, ny, Element.FIRE)
		elif nearby == Element.OIL and randf() < 0.3:  # Slower oil ignition from lava
			set_element(nx, ny, Element.FIRE)
			# Create smoke but less frequently
			if randf() < 0.4:
				create_smoke_from_oil(nx, ny)

func create_fire_spread(wood_x: int, wood_y: int):
	# Create fire particles around burning wood for visual effect
	var spread_directions = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0), Vector2i(1, 0),
		Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)
	]
	
	for dir in spread_directions:
		var nx = wood_x + dir.x
		var ny = wood_y + dir.y
		if get_element(nx, ny) == Element.EMPTY and randf() < 0.4:
			set_element(nx, ny, Element.FIRE)
		elif get_element(nx, ny) == Element.WOOD and randf() < 0.2:
			set_element(nx, ny, Element.FIRE)

func create_smoke_from_oil(oil_x: int, oil_y: int):
	# Create smoke above burning oil
	var smoke_positions = [
		Vector2i(0, -1), Vector2i(-1, -1), Vector2i(1, -1),
		Vector2i(0, -2), Vector2i(-1, -2), Vector2i(1, -2)
	]
	
	for pos in smoke_positions:
		var nx = oil_x + pos.x
		var ny = oil_y + pos.y
		if get_element(nx, ny) == Element.EMPTY and randf() < 0.5:
			set_element(nx, ny, Element.SMOKE)

func update_fire(x: int, y: int):
	# Fire burns out after some time but lasts longer for dramatic effect
	if randf() < 0.01:  # 1% chance to extinguish (burns even longer)
		set_element(x, y, Element.EMPTY)
		return
	
	# Fire spreads to nearby flammable materials more slowly
	var directions = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for dir in directions:
		var nx = x + dir.x
		var ny = y + dir.y
		var nearby = get_element(nx, ny)
		
		if nearby == Element.WATER:
			# Water extinguishes fire
			set_element(x, y, Element.EMPTY)
			return
		elif nearby == Element.WOOD and randf() < 0.08:  # Much slower wood burning
			# Wood first turns to charcoal when touched by fire
			set_element(nx, ny, Element.CHARCOAL)
		elif nearby == Element.OIL and randf() < 0.25:  # Slower oil ignition
			# Fire spreads to oil but slower
			set_element(nx, ny, Element.FIRE)
			# Less frequent smoke creation
			if randf() < 0.15:
				create_smoke_above(nx, ny)

func create_smoke_above(fire_x: int, fire_y: int):
	# Create smoke particle above fire
	if get_element(fire_x, fire_y - 1) == Element.EMPTY:
		set_element(fire_x, fire_y - 1, Element.SMOKE)
	elif get_element(fire_x, fire_y - 2) == Element.EMPTY and randf() < 0.5:
		set_element(fire_x, fire_y - 2, Element.SMOKE)

func update_wood(x: int, y: int):
	# Wood is static but can char when touching fire or lava
	var directions = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for dir in directions:
		var nx = x + dir.x
		var ny = y + dir.y
		var nearby = get_element(nx, ny)
		
		if nearby == Element.FIRE and randf() < 0.05:  # Very slow charring from fire
			set_element(x, y, Element.CHARCOAL)
			return
		elif nearby == Element.LAVA and randf() < 0.12:  # Slightly faster from lava
			set_element(x, y, Element.CHARCOAL)
			return

func update_charcoal(x: int, y: int):
	# Charcoal can slowly burn away or ignite into fire
	var directions = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for dir in directions:
		var nx = x + dir.x  
		var ny = y + dir.y
		var nearby = get_element(nx, ny)
		
		if nearby == Element.FIRE and randf() < 0.02:
			# Charcoal can reignite
			set_element(x, y, Element.FIRE)
			return
		elif nearby == Element.LAVA and randf() < 0.08:
			# Lava burns charcoal away faster
			set_element(x, y, Element.FIRE)
			return
	
	# Charcoal slowly burns away on its own if near heat sources
	if randf() < 0.001:  # Very slow burn away
		set_element(x, y, Element.EMPTY)

func update_oil(x: int, y: int):
	# Oil behaves like water but slower and more viscous
	var move_chance = 0.6  # Slower than water (which is 100%)
	
	if randf() < move_chance:
		if get_element(x, y + 1) == Element.EMPTY:
			set_element(x, y, Element.EMPTY)
			set_element(x, y + 1, Element.OIL)
		else:
			# Oil spreads sideways but slower than water
			var directions = [-1, 1]
			directions.shuffle()
			for dir in directions:
				if get_element(x + dir, y) == Element.EMPTY and randf() < 0.7:
					set_element(x, y, Element.EMPTY)
					set_element(x + dir, y, Element.OIL)
					break
	
	# Check for fire and lava nearby - oil ignites but not instantly
	var directions = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for dir in directions:
		var nx = x + dir.x
		var ny = y + dir.y
		var nearby = get_element(nx, ny)
		
		if nearby == Element.FIRE and randf() < 0.15:  # Slower ignition
			set_element(x, y, Element.FIRE)
			# Less frequent smoke creation
			if randf() < 0.3:
				create_smoke_from_oil(x, y)
			return
		elif nearby == Element.LAVA and randf() < 0.4:  # Still ignites from lava but slower
			set_element(x, y, Element.FIRE)
			create_smoke_from_oil(x, y)
			return

func update_steam(x: int, y: int):
	# Steam rises upward (opposite of falling)
	if get_element(x, y - 1) == Element.EMPTY:
		set_element(x, y, Element.EMPTY)
		set_element(x, y - 1, Element.STEAM)
	else:
		# Steam spreads sideways when blocked from rising
		var directions = [-1, 1]
		directions.shuffle()
		for dir in directions:
			if get_element(x + dir, y) == Element.EMPTY:
				set_element(x, y, Element.EMPTY)
				set_element(x + dir, y, Element.STEAM)
				break
	
func update_smoke(x: int, y: int):
	# Smoke rises like steam but disperses faster
	var move_chance = 0.8  # Smoke moves more frequently than steam
	
	if randf() < move_chance:
		# Try to rise first
		if get_element(x, y - 1) == Element.EMPTY:
			set_element(x, y, Element.EMPTY)
			set_element(x, y - 1, Element.SMOKE)
		else:
			# Spread sideways when blocked
			var directions = [-1, 1]
			directions.shuffle()
			for dir in directions:
				if get_element(x + dir, y) == Element.EMPTY and randf() < 0.7:
					set_element(x, y, Element.EMPTY)
					set_element(x + dir, y, Element.SMOKE)
					break
	
	# Smoke disperses/disappears over time
	if randf() < 0.02:  # 2% chance to disperse
		set_element(x, y, Element.EMPTY)

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

func check_fire_interaction(x: int, y: int):
	var directions = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for dir in directions:
		var nx = x + dir.x
		var ny = y + dir.y
		if get_element(nx, ny) == Element.FIRE:
			# Water touching fire creates steam and extinguishes fire
			set_element(x, y, Element.STEAM)
			set_element(nx, ny, Element.EMPTY)
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
