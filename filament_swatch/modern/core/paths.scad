include <vars.scad>
include <BOSL2/rounding.scad>

// Base outline path points go clockwise from bottom right
function get_base_path() = 
    let(h = BASE_HEIGHT/2,
        w = BASE_WIDTH/2)
    [
        [w - CHAMFER_RIGHT, -h],           // End of right chamfer
        [w, CHAMFER_RIGHT - h],            // Right corner point
        [w, h - CHAMFER_RIGHT],            // Start of right chamfer
        [w - CHAMFER_RIGHT, h],            // End of right chamfer
        [-w + CHAMFER_LEFT, h],            // End of left chamfer
        [-w, h - CHAMFER_LEFT],            // Left corner point
        [-w, -h + CHAMFER_LEFT],           // Left corner point
        [-w + CHAMFER_LEFT, -h]            // End of left chamfer
    ];

// Get the inner path after offset
function get_inner_path() = 
    offset(get_base_path(), r = -INNER_WALL_OFFSET, closed = true, check_valid = false);

// Get the shelf path points
function get_shelf_points() = 
    let(inner_path = get_inner_path())
    [for (i = [0:len(inner_path) - 1]) 
        if (i == 5)  // Left top corner
            [inner_path[i].x + LEFT_SHELF_OFFSET, inner_path[i].y + LEFT_SHELF_OFFSET] 
        else if (i == 6)  // Left bottom corner
            [inner_path[i].x + LEFT_SHELF_OFFSET, inner_path[i].y - LEFT_SHELF_OFFSET] 
        else
            [inner_path[i].x, inner_path[i].y]];

// Get handle path points (left side points) from inner path
function get_handle_path(inner_path) = [for (i = [4:7]) inner_path[i]];  // Left side points from top to bottom

// Get rounded versions of paths
function get_rounded_base_path() = 
    round_corners(get_base_path(), radius=CORNER_RADIUS, $fn=SEGMENTS);

function get_rounded_inner_path() = 
    round_corners(get_inner_path(), radius=CORNER_RADIUS, $fn=SEGMENTS);

function get_rounded_handle_path() = 
    round_corners(get_handle_path(get_inner_path()), radius=CORNER_RADIUS, $fn=SEGMENTS);
