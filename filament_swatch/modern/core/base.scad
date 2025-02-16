include <BOSL2/rounding.scad>
include <BOSL2/std.scad>
include <paths.scad>
include <vars.scad>

/**
 * Creates the main outer frame with inner cutout
 */
module frame()
{
    attachable(size = [ BASE_WIDTH, BASE_HEIGHT, BASE_THICKNESS ], orient = TOP)
    {
        down(BASE_THICKNESS / 2) union()
        {
            difference()
            {
                offset_sweep(get_rounded_base_path(), 
                           height = BASE_THICKNESS - P_EPSILON,
                           bottom = os_circle(r = CORNER_RADIUS), 
                           top = os_circle(r = CORNER_RADIUS),
                           check_valid = false);

                // Inner cutout
                down(P_EPSILON) 
                    offset_sweep(offset(get_rounded_inner_path(), r = -P_EPSILON),
                               height = BASE_THICKNESS - P_EPSILON, 
                               check_valid = false);
                
                // Top roundover
                up(SHELF_THICKNESS)  // Cut down from shelf level
                    offset_sweep(get_rounded_inner_path(), 
                               height = BASE_THICKNESS - SHELF_THICKNESS + P_EPSILON,
                               top = os_circle(r = -INNER_ROUNDOVER), 
                               check_valid = false);
            }
        }

        children();
    }
}

/**
 * Creates the left side shelf extension
 */
module shelf(anchor=CENTER, spin=0, orient=TOP)
{
    inner_path = get_inner_path();

    left_edge_x = inner_path[4].x;
    right_edge_x = inner_path[1].x;
    top_y = inner_path[0].y;
    bottom_y = inner_path[3].y;

    shelf_width = abs(right_edge_x - left_edge_x);
    shelf_height = abs(top_y - bottom_y);
    center_y = (top_y + bottom_y) / 2;
    center_x = left_edge_x + shelf_width / 2;

    right(center_x)
    back(center_y)
    down(BASE_THICKNESS / 2)
    up(SHELF_THICKNESS / 2)
        attachable(size=[shelf_width, shelf_height, SHELF_THICKNESS - P_EPSILON], 
                  anchor=anchor, spin=spin, orient=orient) {
                    tag_scope() diff()
            // First child: the shape to manage
            
                {
                    cuboid([shelf_width, shelf_height, SHELF_THICKNESS - P_EPSILON], anchor=CENTER);
                    left(shelf_width/2 + 0.5)
                        cuboid([1, shelf_height, SHELF_THICKNESS - P_EPSILON], anchor=CENTER);
                }
                children(0);
            
        }
    
}

/**
 * Creates all cutouts (handle and top inner)
 */
module handle_cutout()
{
    down(BASE_THICKNESS/2)  // Base position
    down(P_EPSILON)
        offset_sweep(path = get_rounded_handle_path(), 
                    height = SHELF_THICKNESS + P_EPSILON,  // Only up to shelf height
                    bottom = os_circle(r = -INNER_ROUNDOVER), 
                    check_valid = false);
}


module base()
{
    recolor("SteelBlue")
    diff("remove")
    {
        union()
        {
            frame() if ($children > 0) children(0);
            shelf() show_anchors(s=5) if ($children > 1) children(1);
        }
         tag("remove") handle_cutout();
    }
}