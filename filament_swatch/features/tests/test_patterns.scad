/*
Test pattern modules for filament swatch
Contains test features for evaluating print quality:
- Test circles for dimensional accuracy
- Wall thickness tests
- Overhang test
- Bridging test
*/

include <../../core/base_geometry.scad>
include <../../core/swatch_constants.scad>

/* [Test Pattern Constants] */
TEST_CIRCLES = 6; // Number of test circles
// Spacing between test circles
TEST_CIRCLE_SPACING = 2.5;
// Main test circle radius
TEST_CIRCLE_RADIUS = 2;
// Filament holder dimensions
FILAMENT_RADIUS = 1.8 / 2;
FILAMENT_HOLDER_OFFSET = 1;

// === Wall Test Parameters ===
// Cut test dimensions
CUT_SHIFT = 5;
CUT_WIDTH = 1;
CUT_DEPTH_RATIO = 0.97;
WALL_START = 0.5;
WALL_STEP = 0.1;
WALL_COUNT = 5;

// === Test Feature Parameters ===
TEST_Z_OFFSET = 0.1;     // Small z-offset for clean cuts
TEST_EXTRA_HEIGHT = 0.2; // Extra height for clean cuts through base

/*
Creates test pattern cutouts for circles and wall tests
*/
module rounded_square_test_pattern() {
  // Add test pattern cutouts
  for (i = [0:TEST_CIRCLES]) {
    // circle top left with round test pattern
    translate([
      SWATCH_WALL + TEST_CIRCLE_RADIUS +
          TEST_CIRCLE_RADIUS * TEST_CIRCLE_SPACING * i,
      SWATCH_HEIGHT - SWATCH_WALL - TEST_CIRCLE_RADIUS, SWATCH_THICKNESS / 2 -
      TEST_Z_OFFSET
    ]) cylinder(r = TEST_CIRCLE_RADIUS,
                h = SWATCH_THICKNESS + TEST_EXTRA_HEIGHT, center = true);

    if (i == TEST_CIRCLES) // filament holder
    {
      // filament container
      translate([
        SWATCH_WALL + TEST_CIRCLE_RADIUS +
            TEST_CIRCLE_RADIUS * TEST_CIRCLE_SPACING * i,
        SWATCH_HEIGHT + TEST_Z_OFFSET + FILAMENT_HOLDER_OFFSET,
        FILAMENT_RADIUS +
        TEST_EXTRA_HEIGHT
      ]) rotate([ 90, 0, 0 ])
          cylinder(r = FILAMENT_RADIUS,
                   h = TEST_CIRCLE_RADIUS * 2 + SWATCH_WALL + 2 + 1,
                   center = false);
    }
  }

  // cuts
  cutin = SWATCH_WALL * CUT_DEPTH_RATIO;
  for (i = [0:WALL_COUNT - 1]) {
    wallwide = WALL_START + WALL_STEP * i;
    translate([
      SWATCH_WIDTH - CUT_SHIFT - (CUT_WIDTH + wallwide) * i, -TEST_Z_OFFSET, -
      TEST_Z_OFFSET
    ])
        cube([
          CUT_WIDTH, cutin + TEST_Z_OFFSET, SWATCH_OUTER_THICKNESS +
          TEST_EXTRA_HEIGHT
        ]);
  }

  // overhang
  i = WALL_COUNT - 1;
  short_x = (SWATCH_WIDTH - 2 * CUT_SHIFT -
             (CUT_WIDTH + WALL_START + WALL_STEP * i) * i);
  translate([ CUT_SHIFT, -.01, -SWATCH_OUTER_THICKNESS ])
      rotate([ 0, -asin(2 * SWATCH_OUTER_THICKNESS / short_x), 0 ])
          cube([ short_x, cutin, SWATCH_OUTER_THICKNESS ]);
}

/*
Creates all test pattern features for the swatch.
Combines cutouts and raised features in one place.
Parameters:
    steparea_h: Height of step area
    mode: "cutouts" for cutouts, "additions" for raised features
*/
module create_all_test_features(steparea_h, mode = "cutouts") {
  // Cutouts (to be used in difference())
  module test_cutouts() {
    rounded_square_test_pattern();
    step_pattern_cutouts(steparea_h);
  }
  
  // Additions (to be added after difference())
  module test_additions() {
    step_test_pattern(steparea_h);
    rounded_square_test_pattern_raised(TEST_CIRCLES);
  }
  
  if (mode == "cutouts") test_cutouts();
  else if (mode == "additions") test_additions();
}