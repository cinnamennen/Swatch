/*
Advanced test features for filament swatch
Contains raised test features for evaluating complex print capabilities
*/

include <../../core/swatch_constants.scad>
include <test_patterns.scad>

/* [Advanced Test Constants] */
// === Position Parameters ===
TEST_SPACING = 2.5;  // Base spacing multiplier between tests

// === Sphere Test Parameters ===
SPHERE_OVERHANG_FACTOR = 1.13;  // Creates slight overhang for testing

/*
Creates raised test features for evaluating print quality.
Parameter:
    test_count: Number of test features to create (0-6)
*/
module rounded_square_test_pattern_raised(test_count) {
    //sphere test
    if(test_count>=1)
        translate([SWATCH_WALL+TEST_CIRCLE_RADIUS+TEST_CIRCLE_RADIUS*TEST_CIRCLE_SPACING,
                  SWATCH_HEIGHT-SWATCH_WALL-TEST_CIRCLE_RADIUS,
                  SWATCH_THICKNESS/2])
            intersection()
            {
                cylinder(r=TEST_CIRCLE_RADIUS, h=SWATCH_THICKNESS, center=true);
                translate([0,0,-TEST_CIRCLE_RADIUS+SWATCH_THICKNESS/2*0])
                    sphere(r=TEST_CIRCLE_RADIUS*SPHERE_OVERHANG_FACTOR);
            }
    
    //cylinder/hole test
    if(test_count>=2)
    {
        r_testhole = .5;
        r_testcylinder = r_testhole+.5;
        translate([SWATCH_WALL+TEST_CIRCLE_RADIUS+TEST_CIRCLE_RADIUS*TEST_CIRCLE_SPACING*2,
                  SWATCH_HEIGHT-SWATCH_WALL-TEST_CIRCLE_RADIUS,
                  SWATCH_THICKNESS/2])
            difference()
            {
                union()
                {
                    cylinder(r=r_testcylinder, h=SWATCH_THICKNESS, center=true);
                    translate([-r_testhole,-TEST_CIRCLE_RADIUS,-SWATCH_THICKNESS/2])
                        cube([r_testhole*2,TEST_CIRCLE_RADIUS*2,.2]);
                }
                cylinder(r=r_testhole, h=SWATCH_THICKNESS+TEST_EXTRA_HEIGHT, center=true);
            }
    }

    //bridge test
    if(test_count>=3)
    {
        translate([SWATCH_WALL+TEST_CIRCLE_RADIUS+TEST_CIRCLE_RADIUS*TEST_CIRCLE_SPACING*3,
                  SWATCH_HEIGHT-SWATCH_WALL-TEST_CIRCLE_RADIUS,
                  SWATCH_THICKNESS/2])
            translate([-TEST_CIRCLE_RADIUS/2,-TEST_CIRCLE_RADIUS,0])
                cube([TEST_CIRCLE_RADIUS,TEST_CIRCLE_RADIUS*2,0.2]);
    }

    //hanging cylinder test
    if(test_count>=4)
    {
        testradius = (SWATCH_THICKNESS-0.3)/2;
        translate([SWATCH_WALL+TEST_CIRCLE_RADIUS+TEST_CIRCLE_RADIUS*TEST_CIRCLE_SPACING*4,
                  SWATCH_HEIGHT-SWATCH_WALL-TEST_CIRCLE_RADIUS*0.5,
                  SWATCH_THICKNESS-testradius])
            rotate([90,0,0])
                cylinder(r=testradius,h=TEST_CIRCLE_RADIUS*1.7,center=false);
    }

    //pyramid test
    if(test_count>=5)
    {
        translate([SWATCH_WALL+TEST_CIRCLE_RADIUS+TEST_CIRCLE_RADIUS*TEST_CIRCLE_SPACING*5,
                  SWATCH_HEIGHT-SWATCH_WALL-TEST_CIRCLE_RADIUS*2,
                  SWATCH_THICKNESS/2])
            rotate([-90,45,0])
                cylinder(d1=SWATCH_THICKNESS*sqrt(2),d2=0,h=SWATCH_THICKNESS,$fn=4);
        translate([SWATCH_WALL+TEST_CIRCLE_RADIUS+TEST_CIRCLE_RADIUS*TEST_CIRCLE_SPACING*5,
                  SWATCH_HEIGHT-SWATCH_WALL,SWATCH_THICKNESS/2])
            intersection()
            {
                rotate([90,0,0])
                    cylinder(d1=SWATCH_THICKNESS*sqrt(2),d2=0,h=SWATCH_THICKNESS,$fn=4);
                cube([3*SWATCH_THICKNESS,3*SWATCH_THICKNESS,SWATCH_THICKNESS],center=true);
            }
    }
} 