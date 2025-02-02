include <../core/swatch_constants.scad>
include <../../BOSL2/std.scad>
include <../../BOSL2/rounding.scad>

// Turn on BOSL2 debugging
$show_anchors = true;
$debugger = true;

// Our new geometric recreation
module recreation() {
    // Base dimensions
    width = 84.5;
    height = 37;
    thickness = 3.31;
    
    // Create base shape with chamfered corners
    base = [
        [width-4, 0],      // End of chamfer
        [width, 4],        // Corner point
        [width, height-4], // Start of chamfer
        [width-4, height], // End of chamfer
        [12, height],      // End of chamfer
        [0, height-12],    // Corner point
        [0, 12],          // Corner point
        [12, 0]           // End of chamfer
    ];
    
    // Round all transition points with consistent radius
    rounded_base = round_corners(base, 
        radius=0.5,  // 0.5mm rounding everywhere
        $fn=32
    );
    rounded_inner = round_corners(
        offset(base, r=-3, closed=true, check_valid=false),  // Increased to -2mm for 2mm flat surface
        radius=0.5,  // Same 0.5mm rounding for inner path
        $fn=32
    );
    
    difference() {
        // Outer shell with rounded edges
        offset_sweep(rounded_base, 
            height=thickness, 
            check_valid=false, 
            steps=32,
            bottom=os_circle(r=0.5),
            top=os_circle(r=0.5)
        );
        
        // Inner cutout with rounded edges
        up(-0.4)
        offset_sweep(
            rounded_inner,
            height=thickness+0.4001, 
            steps=32, 
            check_valid=false,
            bottom=os_circle(r=-0.5),
            top=os_circle(r=-0.5)
        );
    }
}

