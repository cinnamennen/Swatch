include <BOSL2/rounding.scad>
include <vars.scad>

// Base outline path points go clockwise from bottom right
BASE_PATH =
  let(h = BASE_HEIGHT / 2, w = BASE_WIDTH / 2) [[w - CHAMFER_RIGHT, -h],   // End of right chamfer
                                                [w, CHAMFER_RIGHT - h],    // Right corner point
                                                [w, h - CHAMFER_RIGHT],    // Start of right chamfer
                                                [w - CHAMFER_RIGHT, h],    // End of right chamfer
                                                [-w + CHAMFER_LEFT, h],    // End of left chamfer
                                                [-w, h - CHAMFER_LEFT],    // Left corner point
                                                [-w, -h + CHAMFER_LEFT],   // Left corner point
                                                [-w + CHAMFER_LEFT, -h]];  // End of left chamfer

INNER_PATH = offset(BASE_PATH, r = -INNER_WALL_OFFSET, closed = true, check_valid = false);

// Handle path indices (left side points)
HANDLE_PATH_INDICES = [ LEFT_TOP_CHAMFER, LEFT_TOP_CORNER, LEFT_BOTTOM_CORNER, LEFT_BOTTOM_CHAMFER ];

ROUNDED_BASE_PATH = round_corners(BASE_PATH, radius = CORNER_RADIUS, $fn = SEGMENTS);
ROUNDED_INNER_PATH = round_corners(INNER_PATH, radius = CORNER_RADIUS, $fn = SEGMENTS);
ROUNDED_HANDLE_PATH =
  round_corners([for (i = HANDLE_PATH_INDICES) INNER_PATH[i]], radius = CORNER_RADIUS, $fn = SEGMENTS);
// height

SHELF_WIDTH = abs(INNER_PATH[1].x - INNER_PATH[4].x);
SHELF_HEIGHT = abs(INNER_PATH[0].y - INNER_PATH[3].y);

INNER_WIDTH = SHELF_WIDTH + LEFT_SHELF_OFFSET;