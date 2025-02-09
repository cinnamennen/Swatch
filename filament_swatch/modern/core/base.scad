include <BOSL2/rounding.scad>
include <BOSL2/std.scad>
include <vars.scad>
include <paths.scad>

/**
 * Creates a swatch holder with the following features:
 * - Chamfered corners
 * - Rounded edges
 * - Left side shelf extension
 * - Handle cutout on the left side
 *
 * All dimensions in millimeters.
 */
module base(anchor=CENTER, spin=0, orient=UP)
{
    // Get all paths - already centered and rounded
    shelf_path = get_shelf_points();
    rounded_base = get_rounded_base_path();
    rounded_inner = get_rounded_inner_path();
    handle_path = get_rounded_handle_path();

    // Make the base attachable
    attachable(anchor, spin, orient, size=[BASE_WIDTH, BASE_HEIGHT, BASE_THICKNESS]) {
        color("SteelBlue", 1.0)
        down(BASE_THICKNESS/2)  // Center in Z axis
        difference() {
            union() {
                // Base with cutout
                difference() {
                    // Outer shell
                    offset_sweep(rounded_base, 
                        height=BASE_THICKNESS,
                        bottom=os_circle(r=CORNER_RADIUS), 
                        top=os_circle(r=CORNER_RADIUS),
                        check_valid=false
                    );
                    // Inner cutout
                        offset_sweep(rounded_inner, 
                            height=BASE_THICKNESS,
                            check_valid=false
                        );
                }
                // Add shelf
                    linear_extrude(height=SHELF_THICKNESS) 
                        polygon(shelf_path);
            }
            // Handle cutout
            down(P_EPSILON)
                offset_sweep(path=handle_path, 
                    height=BASE_THICKNESS,
                    bottom=os_circle(r=-INNER_ROUNDOVER),
                    top=os_circle(r=-INNER_ROUNDOVER),
                    check_valid=false
                );
            // Top inner cutout
            up(SHELF_THICKNESS)
            up(P_EPSILON)
                offset_sweep(rounded_inner, 
                    height=BASE_THICKNESS - SHELF_THICKNESS,
                    top=os_circle(r=-INNER_ROUNDOVER),
                    check_valid=false
                );
        }
        children();
    }
}