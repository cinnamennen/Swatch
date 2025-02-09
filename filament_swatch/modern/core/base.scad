include <BOSL2/rounding.scad>
include <BOSL2/std.scad>
include <paths.scad>
include <vars.scad>

// Debug visualization of inner path points

/**
 * Creates the main outer frame with inner cutout
 */
module frame()
{
    attachable(size=[BASE_WIDTH, BASE_HEIGHT, BASE_THICKNESS]) {
        down(BASE_THICKNESS / 2)  // Center in Z axis
        difference()
        {
            // Outer frame
            offset_sweep(get_rounded_base_path(), height = BASE_THICKNESS, bottom = os_circle(r = CORNER_RADIUS),
                         top = os_circle(r = CORNER_RADIUS), check_valid = false);
            // Inner cutout
            offset_sweep(get_rounded_inner_path(), height = BASE_THICKNESS, check_valid = false);
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

    // Calculate dimensions from inner path
    left_edge_x = inner_path[4].x;     // -32.5074 (left side)
    right_edge_x = inner_path[1].x;    // 39.25 (using straight edge)
    top_y = inner_path[0].y;           // 15.5 (using full height)
    bottom_y = inner_path[3].y;        // -15.5 (using full height)

    shelf_width = abs(right_edge_x - left_edge_x);
    shelf_height = abs(top_y - bottom_y);
    center_y = (top_y + bottom_y) / 2;
    z_pos = SHELF_THICKNESS / 2;

    attachable(size=[shelf_width, shelf_height, SHELF_THICKNESS]) {
        down(BASE_THICKNESS / 2)  // Center in Z axis
        union() {
            // Main shelf
            translate([ left_edge_x + shelf_width / 2, center_y, z_pos ])
                cuboid([ shelf_width, shelf_height, SHELF_THICKNESS ], anchor = CENTER);
                
            // 1mm extension to fill gap
            translate([ left_edge_x - 0.5, center_y, z_pos ])
                cuboid([ 1, shelf_height, SHELF_THICKNESS ], anchor = CENTER);
        }
        children();
    }
}

/**
 * Creates all cutouts (handle and top inner)
 */
module cutouts()
{
    down(BASE_THICKNESS / 2)  // Center in Z axis
    {
        // Handle cutout
        down(P_EPSILON) offset_sweep(path = get_rounded_handle_path(), height = BASE_THICKNESS,
                                     bottom = os_circle(r = -INNER_ROUNDOVER), top = os_circle(r = -INNER_ROUNDOVER),
                                     check_valid = false);
        // Top inner cutout
        up(SHELF_THICKNESS) up(P_EPSILON) offset_sweep(get_rounded_inner_path(), height = BASE_THICKNESS - SHELF_THICKNESS,
                                                       top = os_circle(r = -INNER_ROUNDOVER), check_valid = false);
    }
}

/**
 * Creates a swatch holder with the following features:
 * - Chamfered corners
 * - Rounded edges
 * - Left side shelf extension
 * - Handle cutout on the left side
 *
 * All dimensions in millimeters.
 */
module base(anchor = CENTER, spin = 0, orient = UP)
{
    // Make the base attachable
    attachable(anchor, spin, orient, size = [ BASE_WIDTH, BASE_HEIGHT, BASE_THICKNESS ])
    {
        difference()
        {
            union()
            {
                frame();
                shelf();
            }
            cutouts();
        }
        children();
    }
}