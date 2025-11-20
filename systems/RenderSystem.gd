# systems/RenderSystem.gd
class_name RenderSystem
extends Node

var grid: Grid
var element_registry: ElementRegistry

var image: Image
var texture: ImageTexture
var sprite: Sprite2D

var cell_size: float = 4.0

var last_grid_state: Array = []
var dirty: bool = true

func _init(grid_instance: Grid):
	grid = grid_instance

func _ready():
	element_registry = get_node("/root/ElementRegistry")
	setup_rendering()

func setup_rendering():
	# Create image and texture
	image = Image.create(grid.width, grid.height, false, Image.FORMAT_RGB8)
	texture = ImageTexture.create_from_image(image)
	
	# Create sprite to display
	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	update_sprite_transform()
	
	get_tree().root.get_node("Main").add_child(sprite)
	
	last_grid_state = []
	for x in range(grid.width):
		last_grid_state.append([])
		for y in range(grid.height):
			last_grid_state[x].append(Constants.Elements.EMPTY)

func rerender():
	# Only re-render if something changed
	var has_changes = false
	
	for x in range(grid.width):
		for y in range(grid.height):
			var element_id = grid.get_element(x, y)
			
			# Check if this cell changed
			if element_id != last_grid_state[x][y] or dirty:
				has_changes = true
				last_grid_state[x][y] = element_id
				
				var base_color = element_registry.get_element_color(element_id)
				
				# Add grain
				if element_id != Constants.Elements.EMPTY:
					var variation = (randf() - 0.5) * 0.15
					var grain_color = Color(
						clamp(base_color.r + variation, 0, 1),
						clamp(base_color.g + variation, 0, 1),
						clamp(base_color.b + variation, 0, 1)
					)
					image.set_pixel(x, y, grain_color)
				else:
					image.set_pixel(x, y, base_color)
	
	if has_changes or dirty:
		texture.update(image)
		dirty = false

func update_sprite_transform():
	var viewport_size = get_viewport().get_visible_rect().size
	var width_ratio = viewport_size.x / grid.width
	var height_ratio = viewport_size.y / grid.height
	cell_size = min(width_ratio, height_ratio)
	cell_size = max(cell_size, 2.0)
	
	sprite.scale = Vector2(cell_size, cell_size)
	sprite.position = Vector2(grid.width * cell_size / 2, grid.height * cell_size / 2)

func render():
	# Update every pixel with slight color variation
	for x in range(grid.width):
		for y in range(grid.height):
			var element_id = grid.get_element(x, y)
			var base_color = element_registry.get_element_color(element_id)
			
			# Add grain/texture variation (Sandspiel technique)
			if element_id != Constants.Elements.EMPTY:
				var variation = (randf() - 0.5) * 0.15  # ±15% variation
				var grain_color = Color(
					clamp(base_color.r + variation, 0, 1),
					clamp(base_color.g + variation, 0, 1),
					clamp(base_color.b + variation, 0, 1)
				)
				image.set_pixel(x, y, grain_color)
			else:
				image.set_pixel(x, y, base_color)
	
	texture.update(image)
