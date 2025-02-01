/*
Constants for filament swatch dimensions
These dimensions are fixed for compatibility with Jaxels box
*/

/* [Swatch Dimensions] */
SWATCH_WIDTH = 74.75;  // Compatible with Jaxels box
SWATCH_HEIGHT = 37;    // Must be >=26mm
SWATCH_THICKNESS = 2;  // Must be >=0.18mm
SWATCH_OUTER_THICKNESS = 3.31;

// Design parameters
SWATCH_ROUND = 0.5;    // Corner roundness radius
SWATCH_BORDER = 2.5;   // Border width
SWATCH_WALL = 3;       // Wall thickness
SWATCH_HOLE = 2;       // Hole radius (0 for no hole)

/* [Text Parameters] */
// Font settings
TEXT_FONT = "Overpass";  // Default font
TEXT_FONT_HEAVY = "Overpass:style=Heavy";  // Font for emphasized text
TEXT_SIZE_OFFSET = 0.3;  // How much smaller than height the text should be

// Text placement
TEXT_EDGE_MARGIN = 2;    // Extra margin from wall for edge text

// Text depths
TEXT_FONT_DEPTH = 0.6;  // Depth for extruded text
TEXT_RECESS_DEPTH = 1;  // Depth for recessed text