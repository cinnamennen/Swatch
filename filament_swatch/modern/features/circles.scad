include <BOSL2/std.scad>
include <BOSL2/shapes3d.scad>
include <../core/vars.scad>

// Constants for circle tests
TEST_CIRCLE_RADIUS = 3;
TEST_CIRCLE_SPACING = 2;

// Create all circle test features
module create_circle_tests() {
    for (i = [0:6]) {
        right(i * (TEST_CIRCLE_RADIUS * 2 + TEST_CIRCLE_SPACING))
        tag("remove") 
            attach(TOP)
                cyl(d=TEST_CIRCLE_RADIUS*2, h=BASE_THICKNESS*2);
    }
}
