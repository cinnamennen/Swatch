include <BOSL2/std.scad>

/**
 * Creates 7 cylinders arranged in a row at the top left of the shelf
 */
module shelf_cylinders() {
    // Constants for the cylinders
    hole_d = 3;  // 3mm diameter holes
    spacing = 5;  // 5mm between centers
    total_holes = 7;
    
    // Position at top left corner and move in slightly to avoid edge
    attach(TOP+LEFT) {
        fwd(hole_d)  // Move forward from center to get to the corner
            for(i = [0:total_holes-1]) {
                right(i*spacing + hole_d)
                    down(SHELF_THICKNESS)  // Move down by shelf thickness to ensure cut
                    cyl(d=hole_d, h=SHELF_THICKNESS*3, anchor=TOP);  // Make it 3x longer to ensure cut
            }
    }
} 