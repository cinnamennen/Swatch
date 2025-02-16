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
                attach(TOP)
                left(SHELF_WIDTH/2 - TEST_CIRCLE_RADIUS * 2)
                back(SHELF_HEIGHT/2 - TEST_CIRCLE_RADIUS)
                fwd(.5)
                up(P_EPSILON){
    for (i = [0:6]) {
        tag("remove") 

                right(i * (TEST_CIRCLE_RADIUS * 2 + TEST_CIRCLE_SPACING))
                    cyl(d=TEST_CIRCLE_RADIUS*2, h=BASE_THICKNESS*2 + P_EPSILON, anchor=TOP, $fn=SEGMENTS);
    }
    
    tag("keep") 
        right(1 * (TEST_CIRCLE_RADIUS * 2 + TEST_CIRCLE_SPACING))
        down(SHELF_THICKNESS)
                intersection() {
                    sphere(r=(TEST_CIRCLE_RADIUS+.01), $fn=SEGMENTS);
                    up(TEST_CIRCLE_RADIUS) cube(TEST_CIRCLE_RADIUS*2, center=true);
                    }

    right(2 * (TEST_CIRCLE_RADIUS * 2 + TEST_CIRCLE_SPACING)){
        tag("keep") {
            cyl(d=2, h=SHELF_THICKNESS + P_EPSILON, anchor=TOP, $fn=SEGMENTS);
        }
    }
    // tag("keep") 
        
    //         right(1 * (TEST_CIRCLE_RADIUS * 2 + TEST_CIRCLE_SPACING))
    //             diff("remove")
    //             {
    //                 cyl(d=TEST_CIRCLE_RADIUS*2, h=TEST_CIRCLE_RADIUS*2, anchor=TOP, $fn=SEGMENTS);
    //                 tag("remove") {
    //                     // Center hole
    //                     cyl(d=1, h=TEST_CIRCLE_RADIUS*2 + P_EPSILON, anchor=TOP, $fn=SEGMENTS);
    //                     // Top rectangle (left-right)
    //                     up(TEST_CIRCLE_RADIUS*1.5)
    //                         cuboid([TEST_CIRCLE_RADIUS*3, 0.5, 0.5], anchor=CENTER);
    //                     // Bottom rectangle (front-back)
    //                     up(TEST_CIRCLE_RADIUS*0.5)
    //                         cuboid([0.5, TEST_CIRCLE_RADIUS*3, 0.5], anchor=CENTER);
    //         }
    //     }
    }
}
