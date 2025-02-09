include <vars.scad>

// Base outline path points go clockwise from bottom right
function get_base_path() = 
    let(h = BASE_HEIGHT/2)
    [
        [BASE_WIDTH - CHAMFER_RIGHT, -h],           // End of right chamfer
        [BASE_WIDTH, CHAMFER_RIGHT - h],            // Right corner point
        [BASE_WIDTH, h - CHAMFER_RIGHT],            // Start of right chamfer
        [BASE_WIDTH - CHAMFER_RIGHT, h],            // End of right chamfer
        [CHAMFER_LEFT, h],                          // End of left chamfer
        [0, h - CHAMFER_LEFT],                      // Left corner point
        [0, -h + CHAMFER_LEFT],                     // Left corner point
        [CHAMFER_LEFT, -h]                          // End of left chamfer
    ];

// Get the inner path after offset
function get_inner_path() = 
    offset(get_base_path(), r = -(INNER_WALL_OFFSET), closed = true, check_valid = false);

// Get the shelf path points
function get_shelf_points() = 
    let(inner_path = get_inner_path())
    [for (i = [0:len(inner_path) - 1]) 
        if (i == 5)  // Left top corner
            [inner_path[i].x + LEFT_SHELF_OFFSET + P_EPSILON, inner_path[i].y + LEFT_SHELF_OFFSET + P_EPSILON] 
        else if (i == 6)  // Left bottom corner
            [inner_path[i].x + LEFT_SHELF_OFFSET + P_EPSILON, inner_path[i].y - LEFT_SHELF_OFFSET - P_EPSILON] 
        else
            [inner_path[i].x + P_EPSILON, inner_path[i].y]];

// Get handle path points (left side points) from inner path
function get_handle_path(inner_path) = [for (i = [4:7]) inner_path[i]];  // Left side points from top to bottom
