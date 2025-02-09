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

                offset_sweep(get_rounded_base_path(), height = BASE_THICKNESS - P_EPSILON,
                             bottom = os_circle(r = CORNER_RADIUS), top = os_circle(r = CORNER_RADIUS),
                             check_valid = false);

                down(P_EPSILON) offset_sweep(offset(get_rounded_inner_path(), r = -P_EPSILON),
                                             height = BASE_THICKNESS - P_EPSILON, check_valid = false);
            }
        }

        children();
    }
}

/**
 * Creates the left side shelf extension
 */
module shelf()
{
    inner_path = get_inner_path();

    left_edge_x = inner_path[4].x;
    right_edge_x = inner_path[1].x;
    top_y = inner_path[0].y;
    bottom_y = inner_path[3].y;

    shelf_width = abs(right_edge_x - left_edge_x);
    shelf_height = abs(top_y - bottom_y);
    center_y = (top_y + bottom_y) / 2;
    z_pos = SHELF_THICKNESS / 2;

    attachable(size = [ shelf_width, shelf_height, SHELF_THICKNESS ], orient = TOP)
    {
        down(BASE_THICKNESS / 2) union()
        {

            translate([ left_edge_x + shelf_width / 2 + P_EPSILON, center_y, z_pos ])
                cuboid([ shelf_width - P_EPSILON, shelf_height - 2 * P_EPSILON, SHELF_THICKNESS ], anchor = CENTER);

            translate([ left_edge_x - 0.5 + P_EPSILON, center_y, z_pos ])
                cuboid([ 1, shelf_height - 2 * P_EPSILON, SHELF_THICKNESS ], anchor = CENTER);
        }

        children();
    }
}

/**
 * Creates all cutouts (handle and top inner)
 */
module cutouts()
{
    down(BASE_THICKNESS / 2)
    {
        down(P_EPSILON) offset_sweep(path = get_rounded_handle_path(), height = BASE_THICKNESS + 2 * P_EPSILON,
                                     bottom = os_circle(r = -INNER_ROUNDOVER), top = os_circle(r = -INNER_ROUNDOVER),
                                     check_valid = false);
        up(SHELF_THICKNESS - P_EPSILON)
            offset_sweep(get_rounded_inner_path(), height = BASE_THICKNESS - SHELF_THICKNESS + P_EPSILON,
                         top = os_circle(r = -INNER_ROUNDOVER), check_valid = false);
    }
}

module base()
{
    difference()
    {
        union()
        {
            frame() if ($children > 0) children(0);
            shelf() if ($children > 1) children(1);
        }
        cutouts();
    }
}