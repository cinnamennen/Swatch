include <../../BOSL2/rounding.scad>
include <../../BOSL2/std.scad>
include <../core/swatch_constants.scad>

// Turn on BOSL2 debugging
$show_anchors = true;
$debugger = true;

// Constants
LEFT_SHELF_OFFSET = 5; // How far the shelf extends to the left
SHELF_THICKNESS = 4;
// Our new geometric recreation
module recreation() {
  // Base dimensions
  width = 84.5;
  height = 37;
  thickness = 3.31;

  // Chamfer parameters
  chamfer_right = 3.0; // Right side chamfer length
  chamfer_left = 8.5;  // Left side chamfer length

  // Calculate shelf chamfer based on offset, but limit it to less than shelf
  // thickness
  shelf_chamfer =
      min(SHELF_THICKNESS / 2, LEFT_SHELF_OFFSET * (chamfer_left / 8.5) /
                                   4); // Scale down and limit chamfer

  // Create base shape with chamfered corners
  base = [[width - chamfer_right, 0],      // End of right chamfer
          [width, chamfer_right],          // Right corner point
          [width, height - chamfer_right], // Start of right chamfer
          [width - chamfer_right, height], // End of right chamfer
          [chamfer_left, height],          // End of left chamfer
          [0, height - chamfer_left],      // Left corner point
          [0, chamfer_left],               // Left corner point
          [chamfer_left, 0]                // End of left chamfer
  ];

  // Create inner path first
  inner_path = offset(base, r = -3, closed = true, check_valid = false);

  // Round the base and inner paths
  rounded_base = round_corners(base,
                               radius = 0.5, // 0.5mm rounding everywhere
                               $fn = 32);
  rounded_inner =
      round_corners(inner_path,
                    radius = 0.5, // Same 0.5mm rounding for inner path
                    $fn = 32);

  // Create the base with cutout
  difference() {
    // Outer shell with rounded edges
    offset_sweep(rounded_base, height = thickness, check_valid = false,
                 steps = 32, bottom = os_circle(r = 0.5),
                 top = os_circle(r = 0.5));

    // Inner cutout with rounded edges
    offset_sweep(rounded_inner, height = thickness, steps = 32,
                 check_valid = false, bottom = os_circle(r = -0.5),
                 top = os_circle(r = -0.5));
  }

  // Create shelf path by copying base points but adjusting for shelf
  shelf_path = [
    for (i = [0:len(inner_path)-1])
      if (i<=1)
      [inner_path[i].x+.5, inner_path[i].y-.5]
      else if (i<=3)
        [inner_path[i].x+.5, inner_path[i].y+.5]
     
      else if (i==4)
        [inner_path[i].x-.5, inner_path[i].y+.5]
      else if (i==5)
        [inner_path[i].x+LEFT_SHELF_OFFSET-.5, inner_path[i].y+LEFT_SHELF_OFFSET+.5]
      else if (i == 6)  // Adjust left bottom corner
        [inner_path[i].x+LEFT_SHELF_OFFSET-.5, inner_path[i].y-LEFT_SHELF_OFFSET-.5]
      else  // Adjust left bottom point
        [inner_path[i].x-.5, inner_path[i].y-.5]
  ];

  // Create shelf with straight edges
  translate([0, 0, 0])
    linear_extrude(height=SHELF_THICKNESS)
      polygon(shelf_path);

  // Add fillets at the transition points (5 and 6)
  // Top transition (point 5)
  translate([shelf_path[5].x, shelf_path[5].y - 1, 0])
    fillet(l=SHELF_THICKNESS, r=0.5, ang=45, $fn=32,
           orient=UP, spin=180+45, anchor=BOTTOM);
  
  // Bottom transition (point 6)
  translate([shelf_path[6].x, shelf_path[6].y + 1, 0])
    fillet(l=SHELF_THICKNESS, r=0.5, ang=45, $fn=32,
           orient=UP, spin=180-90, anchor=BOTTOM);
}