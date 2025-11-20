# Constants.gd
# Global constants and enums for the entire game
extends Node

# Grid dimensions
const GRID_WIDTH = 200
const GRID_HEIGHT = 150

# Element IDs (enum)
enum Elements {
	EMPTY = 0,
	
	# Solids (1-20)
	SAND = 1,
	STONE = 2,
	WOOD = 3,
	METAL = 4,
	GLASS = 5,
	ICE = 6,
	BRICK = 7,
	CONCRETE = 8,
	
	# Liquids (21-40)
	WATER = 21,
	OIL = 22,
	LAVA = 23,
	ACID = 24,
	NITRO = 25,
	
	# Gases (41-60)
	STEAM = 41,
	SMOKE = 42,
	GAS = 43,
	CO2 = 44,
	
	# Powders (61-80)
	GUNPOWDER = 61,
	SALT = 62,
	DUST = 63,
	
	# Energy (81-100)
	FIRE = 81,
	OIL_FIRE = 82,
	ELECTRICITY = 83,
	PLASMA = 84,
	
	# Special (101-120)
	CLONE = 101,
	VIRUS = 102,
	VOID = 103,
	PLANT = 104,
	
	# Dynamic/Temporary (121+)
	CHARCOAL = 121,
}

# Element categories for UI
enum Category {
	SOLIDS,
	LIQUIDS,
	GASES,
	POWDERS,
	ENERGY,
	SPECIAL
}

# Element states
enum State {
	SOLID,
	LIQUID,
	GAS,
	POWDER,
	ENERGY,
	SPECIAL
}

# Temperature constants (Celsius)
const ABSOLUTE_ZERO = -273.0
const WATER_FREEZE = 0.0
const ROOM_TEMP = 20.0
const WATER_BOIL = 100.0
const FIRE_TEMP = 600.0
const LAVA_TEMP = 1200.0
const PLASMA_TEMP = 3000.0

# Physics constants
const GRAVITY = 1.0
const MAX_PRESSURE = 100.0
const HEAT_DIFFUSION_RATE = 0.1
