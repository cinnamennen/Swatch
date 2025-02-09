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
    
    eps = $preview ? PREVIEW_EPSILON : 0;  // Only apply epsilon in preview mode

    // Get centered paths
    base_path = [for(p = get_base_path()) 
        [p.x - BASE_WIDTH/2, p.y]];  // Only center X, Y is already centered
    inner_path = [for(p = get_inner_path()) 
        [p.x - BASE_WIDTH/2, p.y]];  // Only center X, Y is already centered
    shelf_path = [for(p = get_shelf_points()) 
        [p.x - BASE_WIDTH/2, p.y]];  // Only center X, Y is already centered

    // Define named anchors for working area corners
    // All anchors point inward (towards origin) along X axis


    // Create rounded paths
    rounded_base = round_corners(base_path, radius=CORNER_RADIUS, $fn=SEGMENTS);
    rounded_inner = round_corners(inner_path, radius=CORNER_RADIUS, $fn=SEGMENTS);
    handle_path = round_corners(
        get_handle_path(inner_path),
        radius=CORNER_RADIUS + eps, 
        $fn=SEGMENTS
    );

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
                        height=BASE_THICKNESS + eps,
                        bottom=os_circle(r=CORNER_RADIUS), 
                        top=os_circle(r=CORNER_RADIUS),
                        check_valid=false
                    );
                    // Inner cutout
                    down(eps)
                        offset_sweep(rounded_inner, 
                            height=BASE_THICKNESS + 3*eps,
                            check_valid=false
                        );
                }
                // Add shelf
                move([eps, eps, 0])
                    linear_extrude(height=SHELF_THICKNESS + eps) 
                        polygon(shelf_path);
            }
            // Handle cutout
            move([-eps, -eps, -eps])
                offset_sweep(path=handle_path, 
                    height=BASE_THICKNESS + 3*eps,
                    bottom=os_circle(r=-INNER_ROUNDOVER - eps),
                    top=os_circle(r=-INNER_ROUNDOVER - eps),
                    check_valid=false
                );
            // Top inner cutout
            up(SHELF_THICKNESS - eps)
                offset_sweep(rounded_inner, 
                    height=BASE_THICKNESS - SHELF_THICKNESS + 3*eps,
                    top=os_circle(r=-INNER_ROUNDOVER - eps),
                    check_valid=false
                );
        }
        children();
    }
}

// Render when this is the main file
base(); 