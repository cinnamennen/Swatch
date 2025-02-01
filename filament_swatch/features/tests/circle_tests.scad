/*
Circular test features for filament swatch
Contains all test features with circular geometry:
- Test circles for dimensional accuracy
- Filament holder
- Sphere overhang test
- Cylinder/hole test
*/

include <../../core/swatch_constants.scad>
include <test_constants.scad>

/*
Calculates the position for a test circle
Parameters:
    circle_index: Index of the circle (0-6)
Returns: [x, y] position array
*/
function calc_circle_position(circle_index) = [
    SWATCH_WALL + TEST_CIRCLE_RADIUS + TEST_CIRCLE_RADIUS*TEST_CIRCLE_SPACING*circle_index,
    SWATCH_HEIGHT - SWATCH_WALL - TEST_CIRCLE_RADIUS
];

/*
Creates basic test circle cutout
Parameters:
    circle_index: Index of the circle (0-6)
*/
module create_test_circle(circle_index) {
    pos = calc_circle_position(circle_index);
    
    translate([pos[0], pos[1], SWATCH_THICKNESS/2-TEST_Z_OFFSET])
        cylinder(r=TEST_CIRCLE_RADIUS, 
                h=SWATCH_THICKNESS+TEST_EXTRA_HEIGHT, 
                center=true);
}

/*
Creates filament holder
Parameters:
    circle_index: Index of the circle to attach holder to
*/
module create_filament_holder() {
    pos = calc_circle_position(6);
    
    translate([pos[0], 
              SWATCH_HEIGHT+TEST_Z_OFFSET+FILAMENT_HOLDER_OFFSET, 
              FILAMENT_RADIUS+TEST_EXTRA_HEIGHT])
        rotate([90,0,0])
            cylinder(r=FILAMENT_RADIUS, 
                    h=TEST_CIRCLE_RADIUS*2+SWATCH_WALL+2+1, 
                    center=false);
}

/*
Creates sphere overhang test
*/
module create_sphere_test(circle_index) {
    pos = calc_circle_position(circle_index);
    
    translate([pos[0], pos[1], SWATCH_THICKNESS/2])
        intersection() {
            cylinder(r=TEST_CIRCLE_RADIUS, h=SWATCH_THICKNESS, center=true);
            translate([0,0,-TEST_CIRCLE_RADIUS+SWATCH_THICKNESS/2*0])
                sphere(r=TEST_CIRCLE_RADIUS*SPHERE_OVERHANG_FACTOR);
        }
}

/*
Creates cylinder with hole test
*/
module create_cylinder_hole_test(circle_index) {
    pos = calc_circle_position(circle_index);
    
    r_testhole = .5;
    r_testcylinder = r_testhole+.5;
    
    translate([pos[0], pos[1], SWATCH_THICKNESS/2])
        difference() {
            union() {
                cylinder(r=r_testcylinder, h=SWATCH_THICKNESS, center=true);
                translate([-r_testhole,-TEST_CIRCLE_RADIUS,-SWATCH_THICKNESS/2])
                    cube([r_testhole*2,TEST_CIRCLE_RADIUS*2,.2]);
            }
            cylinder(r=r_testhole, h=SWATCH_THICKNESS+TEST_EXTRA_HEIGHT, center=true);
        }
}

/*
Creates all circular test features
*/
module create_circle_tests() {
    // Basic test circles
    create_test_circle(0);
    create_test_circle(3);
    create_test_circle(4);
    
    // Advanced tests
    create_sphere_test(1);
    create_cylinder_hole_test(2);
    
    // Basic test circle with filament holder
    create_test_circle(5);
    create_filament_holder();
} 