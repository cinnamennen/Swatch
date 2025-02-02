include <../../BOSL2/rounding.scad>
include <../../BOSL2/std.scad>
include <../core/swatch_constants.scad>

// Turn on BOSL2 debugging
$show_anchors = true;
$debugger = true;

// Constants
LEFT_SHELF_OFFSET = 8; // How far the shelf extends to the left
SHELF_THICKNESS = 2;
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

  difference() {
    // Outer shell with rounded edges
    offset_sweep(rounded_base, height = thickness, check_valid = false,
                 steps = 32, bottom = os_circle(r = 0.5),
                 top = os_circle(r = 0.5));

    // Inner cutout with rounded edges
    up(-0.4)
        offset_sweep(rounded_inner, height = thickness + 0.4001, steps = 32,
                     check_valid = false, bottom = os_circle(r = -0.5),
                     top = os_circle(r = -0.5));
  }

  // Create shelf as chamfered cuboid
  translate([ LEFT_SHELF_OFFSET / 2 + width / 2, height / 2, 0 ])
  diff()
      prismoid(size1 = [ width - LEFT_SHELF_OFFSET - 1, height - 1 ],
               size2 = [ width - LEFT_SHELF_OFFSET - 1, height - 1 ],
               h = SHELF_THICKNESS, chamfer = [
                 chamfer_right, chamfer_left - LEFT_SHELF_OFFSET,
                 chamfer_left - LEFT_SHELF_OFFSET,
                 chamfer_right
               ]) {
    edge_profile([ TOP + LEFT, BOTTOM + LEFT ]) {
      mask2d_roundover(r=.5, mask_angle = $edge_angle, $fn=32);
    }
  }
}