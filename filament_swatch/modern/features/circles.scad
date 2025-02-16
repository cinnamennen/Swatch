include <BOSL2/std.scad>
include <BOSL2/shapes3d.scad>
include <../core/vars.scad>

// Constants for circle tests
TEST_CIRCLE_RADIUS = 2;
TEST_CIRCLE_SPACING = 1;

// Create all circle test features
module create_circle_tests() {
    total_width = 7 * (TEST_CIRCLE_RADIUS * 2 + TEST_CIRCLE_SPACING);
    start_x = -total_width/2 + TEST_CIRCLE_RADIUS;
    
    for (i = [0:6]) {
        tag("remove") 
            attach(TOP)
                left(SHELF_WIDTH/2 - TEST_CIRCLE_RADIUS * 2)
                back(SHELF_HEIGHT/2 - TEST_CIRCLE_RADIUS)
                fwd(.5)
                up(P_EPSILON)
                right(i * (TEST_CIRCLE_RADIUS * 2 + TEST_CIRCLE_SPACING))
                    cyl(d=TEST_CIRCLE_RADIUS*2, h=BASE_THICKNESS*2 + P_EPSILON, anchor=TOP, $fn=SEGMENTS);
    }
}
