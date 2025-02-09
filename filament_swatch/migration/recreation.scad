include <BOSL2/rounding.scad>
include <BOSL2/std.scad>

// Debug settings
$show_anchors = true;
$debugger = true;

// Base dimensions
BASE_WIDTH = 84.5;
BASE_HEIGHT = 37;
BASE_THICKNESS = 3.31;

// Wall and shelf parameters
INNER_WALL_OFFSET = 3;    // How far the inner wall is inset from the outer wall
SHELF_THICKNESS = 2;      // Height of the left shelf
LEFT_SHELF_OFFSET = 5;    // How far the shelf extends to the left

// Chamfer dimensions
CHAMFER_RIGHT = 3.0;      // Right side chamfer length
CHAMFER_LEFT = 8.5;       // Left side chamfer length

// Rounding parameters
CORNER_RADIUS = 0.5;      // Radius for all corner roundovers
INNER_ROUNDOVER = 0.5;    // Radius for inner edge roundovers
SEGMENTS = 32;            // Number of segments for curved surfaces

// Technical parameters
PREVIEW_EPSILON = 0.001;  // Tiny offset to prevent z-fighting in preview

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

/**
 * Creates a swatch holder with the following features:
 * - Chamfered corners
 * - Rounded edges
 * - Left side shelf extension
 * - Handle cutout on the left side
 *
 * All dimensions are in millimeters.
 */
module recreation()
{
    // Parameter validation
    assert(BASE_WIDTH > 0, "Base width must be positive");
    assert(BASE_HEIGHT > 0, "Base height must be positive");
    assert(BASE_THICKNESS > 0, "Base thickness must be positive");
    assert(INNER_WALL_OFFSET < BASE_WIDTH/2, "Inner wall offset too large for base width");
    assert(SHELF_THICKNESS < BASE_THICKNESS, "Shelf thickness must be less than base thickness");
    
    eps = $preview ? EPSILON : 0;  // Only apply epsilon in preview mode

    // Base polygon points
    base = [[BASE_WIDTH - CHAMFER_RIGHT, 0],           // End of right chamfer
            [BASE_WIDTH, CHAMFER_RIGHT],               // Right corner point
            [BASE_WIDTH, BASE_HEIGHT - CHAMFER_RIGHT], // Start of right chamfer
            [BASE_WIDTH - CHAMFER_RIGHT, BASE_HEIGHT], // End of right chamfer
            [CHAMFER_LEFT, BASE_HEIGHT],               // End of left chamfer
            [0, BASE_HEIGHT - CHAMFER_LEFT],           // Left corner point
            [0, CHAMFER_LEFT],                         // Left corner point
            [CHAMFER_LEFT, 0]                          // End of left chamfer
    ];

    // Create and round the paths
    inner_path = offset(base, r = -(INNER_WALL_OFFSET + eps), closed = true, check_valid = false);
    rounded_base = round_corners(base, radius = CORNER_RADIUS, $fn = SEGMENTS);
    rounded_inner = round_corners(inner_path, radius = CORNER_RADIUS, $fn = SEGMENTS);

    // Create shelf path with left extension - add epsilon to the offset to prevent z-fighting
    shelf_path = [for (i = [0:len(inner_path) - 1]) 
        if (i == LEFT_TOP_CORNER)
            [inner_path[i].x + LEFT_SHELF_OFFSET + eps, inner_path[i].y + LEFT_SHELF_OFFSET + eps] 
        else if (i == LEFT_BOTTOM_CORNER)
            [inner_path[i].x + LEFT_SHELF_OFFSET + eps, inner_path[i].y - LEFT_SHELF_OFFSET - eps] 
        else
            [inner_path[i].x + eps, inner_path[i].y]];

    // Handle roundover path - uses points that form the left side handle
    handle_points = [ 
        inner_path[HANDLE_TOP],           // Top of handle
        inner_path[HANDLE_TOP_CORNER],    // Top-left corner
        inner_path[HANDLE_BOTTOM_CORNER], // Bottom-left corner
        inner_path[HANDLE_BOTTOM]         // Bottom of handle
    ];
    handle_path = round_corners(handle_points, radius = CORNER_RADIUS + eps, $fn = SEGMENTS);

    // Construct the final geometry
    color("SteelBlue", 1.0)  // Set a consistent color for the entire model
    difference()
    {
        union()
        {
            // Base with cutout
            difference()
            {
                offset_sweep(rounded_base, height = BASE_THICKNESS + eps, check_valid = false,
                             bottom = os_circle(r = CORNER_RADIUS), top = os_circle(r = CORNER_RADIUS));
                // Make inner cutout slightly larger in preview
                translate([0, 0, -eps])
                    offset_sweep(rounded_inner, height = BASE_THICKNESS + 3*eps, check_valid = false);
            }
            // Add shelf - move slightly out in preview
            translate([eps, eps, 0])
                linear_extrude(height = SHELF_THICKNESS + eps) 
                    polygon(shelf_path);
        }
        // Handle roundover cutout - extend slightly in all directions
        translate([-eps, -eps, -eps])
            offset_sweep(path = handle_path, height = BASE_THICKNESS + 3*eps, 
                        bottom = os_circle(r = -INNER_ROUNDOVER - eps),
                        top = os_circle(r = -INNER_ROUNDOVER - eps), 
                        check_valid = false);
        // Top inner cutout with roundover - extend slightly in all directions
        translate([0, 0, SHELF_THICKNESS - eps])
            offset_sweep(rounded_inner, height = BASE_THICKNESS - SHELF_THICKNESS + 3*eps, 
                        check_valid = false, 
                        top = os_circle(r = -INNER_ROUNDOVER - eps));
    }
}

// Render when this file is the main file
recreation(); 