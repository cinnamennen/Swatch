include <BOSL2/std.scad>
include <vars.scad>
include <paths.scad>

module frame()
{
    attachable(size = [ BASE_WIDTH, BASE_HEIGHT, BASE_THICKNESS ], orient = TOP)
    {
        down(BASE_THICKNESS / 2) union()
        {
            difference()
            {
                offset_sweep(ROUNDED_BASE_PATH, 
                           height = BASE_THICKNESS - P_EPSILON,
                           bottom = os_circle(r = CORNER_RADIUS), 
                           top = os_circle(r = CORNER_RADIUS),
                           check_valid = false);

                // Inner cutout
                down(P_EPSILON) 
                    offset_sweep(offset(ROUNDED_INNER_PATH, r = -P_EPSILON),
                               height = BASE_THICKNESS - P_EPSILON, 
                               check_valid = false);
                
                // Top roundover
                up(SHELF_THICKNESS - P_EPSILON)  // Slightly lower to ensure clean cut
                    offset_sweep(ROUNDED_INNER_PATH, 
                               height = BASE_THICKNESS - SHELF_THICKNESS + 2*P_EPSILON,  // Extend slightly more
                               top = os_circle(r = -INNER_ROUNDOVER), 
                               check_valid = false);
            }
        }

        children();
    }
}