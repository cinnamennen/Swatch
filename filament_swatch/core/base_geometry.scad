/*
Base geometry modules for filament swatch
Contains basic shape generation functions
*/

include <swatch_constants.scad>

/*
Creates a rounded square shape
Parameters:
    x, y: Width and height
    z: Thickness
    r: Corner radius
*/
module rounded_square(x, y, z, r)
{
    delta = r;
    
    hull()
    {
        translate([r,r,0]) cylinder(h=z,r=r);
        translate([-r+x,r,0]) cylinder(h=z,r=r);
        translate([r,-r+y,0]) cylinder(h=z,r=r);
        translate([-r+x,-r+y,0]) cylinder(h=z,r=r);
    }
}

/*
Creates the base swatch shape with beveled edges
*/
module create_base_swatch()
{
    union()
    {
        shifty = SWATCH_BORDER-SWATCH_WALL;
        shiftx = 2*shifty;
        translate([-92.5-shiftx, -86.5-shifty, 0])
            import("../assets/sample.stl");
    
        innerh = SWATCH_HEIGHT-2*SWATCH_BORDER;
        innerw = SWATCH_WIDTH-2*SWATCH_BORDER;
        translate([SWATCH_BORDER-shiftx, SWATCH_BORDER-shifty, 0])
            cube([innerw, innerh, SWATCH_THICKNESS]);
    }
}

// Beveled square shape
module beveled_square(x, y, z, outer_z, r)
{
    bevel_depth = outer_z - z;
    
    difference() {
        // Main body
        rounded_square(x, y, z, r);
        
        // Top bevel
        translate([0, y, z])
            rotate([45,0,0])
                cube([x, bevel_depth*sqrt(2), bevel_depth*sqrt(2)]);
        
        // Bottom bevel
        translate([0, 0, z])
            rotate([45,0,0])
                cube([x, bevel_depth*sqrt(2), bevel_depth*sqrt(2)]);
                
        // Right bevel
        translate([x, 0, z])
            rotate([0,-45,0])
                cube([bevel_depth*sqrt(2), y, bevel_depth*sqrt(2)]);
                
        // Left bevel
        translate([0, 0, z])
            rotate([0,-45,0])
                cube([bevel_depth*sqrt(2), y, bevel_depth*sqrt(2)]);
    }
} 