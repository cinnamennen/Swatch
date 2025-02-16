include <BOSL2/std.scad>

/**
 * Creates 7 cylinders arranged in a row at the top left of the shelf
 */
module shelf_cylinders() {
    // Constants for the cylinders
    hole_d = 3;  // 3mm diameter holes
    spacing = 5;  // 5mm between centers
    total_holes = 7;
    cube_size = 2;  // Size of the inner cube (smaller than hole diameter)
    
    tag("remove") attach(TOP) {
        cyl(d=hole_d, h=SHELF_THICKNESS*3, anchor=CENTER);
    }
    tag("keep") attach(TOP) {
        cuboid([cube_size, cube_size, SHELF_THICKNESS*2], anchor=CENTER);
    }
} 