

// Base dimensions - these are used across multiple components
BASE_WIDTH = 84.5;
BASE_HEIGHT = 37;
BASE_THICKNESS = 3.31;

// Wall and shelf parameters - these might be needed by other components
INNER_WALL_OFFSET = 3;    // How far the inner wall is inset from the outer wall
SHELF_THICKNESS = 2;      // Height of the left shelf
LEFT_SHELF_OFFSET = 5;    // How far the shelf extends to the left

// Chamfer dimensions - might be used for consistent styling
CHAMFER_RIGHT = 3.0;      // Right side chamfer length
CHAMFER_LEFT = 8.5;       // Left side chamfer length

// Rounding parameters - these should be consistent across the project
CORNER_RADIUS = 0.5;      // Radius for all corner roundovers
INNER_ROUNDOVER = 0.5;    // Radius for inner edge roundovers
SEGMENTS = 32;            // Number of segments for curved surfaces

// Derived geometric constants
CORNER_COMPENSATION = 3.5;  // Compensation for double-rounded corners (inner and outer path)

// Technical parameters
PREVIEW_EPSILON = 0.001;  // Tiny offset to prevent z-fighting in preview 
P_EPSILON = $preview ? 0.001 : 0;
// Point indices for the polygon paths
// Base polygon points go clockwise from bottom right
RIGHT_BOTTOM_CHAMFER = 0;
RIGHT_BOTTOM_CORNER = 1;
RIGHT_TOP_CORNER = 2;
RIGHT_TOP_CHAMFER = 3;
LEFT_TOP_CHAMFER = 4;
LEFT_TOP_CORNER = 5;      // Also used for shelf extension
LEFT_BOTTOM_CORNER = 6;   // Also used for shelf extension
LEFT_BOTTOM_CHAMFER = 7;

// Handle points (subset of base polygon)
HANDLE_TOP = LEFT_TOP_CHAMFER;
HANDLE_TOP_CORNER = LEFT_TOP_CORNER;
HANDLE_BOTTOM_CORNER = LEFT_BOTTOM_CORNER;
HANDLE_BOTTOM = LEFT_BOTTOM_CHAMFER; 


assert(BASE_WIDTH > 0, "Base width must be positive");
assert(BASE_HEIGHT > 0, "Base height must be positive");
assert(BASE_THICKNESS > 0, "Base thickness must be positive");
assert(INNER_WALL_OFFSET < BASE_WIDTH / 2, "Inner wall offset too large for base width");
assert(SHELF_THICKNESS < BASE_THICKNESS, "Shelf thickness must be less than base thickness");