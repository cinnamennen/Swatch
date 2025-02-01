/*
Step test patterns for filament swatch
Contains step pattern generation for testing layer heights and bridges
*/

include <../../core/base_geometry.scad>
include <../../core/swatch_constants.scad>
include <../text/text_features.scad>

// Step pattern configuration
STEP_THICKNESSES =
    [ -.6, 0.2, 0.4, 0.6, 0.8, 1.0, 1.6 ]; // Layer heights to test
STEP_TEXT_SIZE = 4;                        // Font size for measurements
STEP_TEXT_HEIGHT = 0.4;                    // Height of text on steps

// === Step Pattern Parameters ===
// Wall thickness around step area
STEP_AREA_DISTANCE = 1.5;

// Text parameters
STEP_TEXT_OFFSET = 2; // Offset from wall for text placement

// Bridge parameters
STEP_BRIDGE_GAP_RATIO = 1 / 3; // Gap for bridges relative to corner radius
STEP_BRIDGE_OFFSET = -0.1;     // Z-offset for bridge cutouts

/*
Calculate step area dimensions
*/
function calc_font_height(text_upper_size, text_lower_size,
                          line_sep) = text_upper_size + line_sep
                                                            * text_lower_size *
                                                            2;

function calc_step_area_height(total_height, wall,
                               font_height) = total_height -
                                              (STEP_AREA_DISTANCE + 1) * wall
                                              - font_height - 2;

function calc_step_area_width(total_width, wall, step_count, step_index) =
    (total_width - (2 * wall)) / step_count * (step_index + 1);

/*
Creates step test pattern with varying layer heights.
Tests printer's ability to handle different layer heights and bridges.

Parameters:
    steparea_h: Height of step area
*/
module step_test_pattern(steparea_h) {
  one_steparea_w = (SWATCH_WIDTH - 2 * SWATCH_WALL) / len(STEP_THICKNESSES);

  for (i = [0:len(STEP_THICKNESSES) - 1]) {
    steparea_w = one_steparea_w * (i + 1);
    translate([ SWATCH_WALL + steparea_w, 0, 0 ]) {
      // Add measurement text
      text_pos_x = -one_steparea_w / 10; // Horizontal text position
      text_pos_y = SWATCH_WALL * STEP_TEXT_OFFSET;
      text_pos_z = STEP_THICKNESSES[i] < 0 ? SWATCH_THICKNESS - STEP_TEXT_HEIGHT
                                           : STEP_THICKNESSES[i];

      translate([ text_pos_x, text_pos_y, text_pos_z ])
          linear_extrude(height = STEP_TEXT_HEIGHT, convexity = 10)
              text(str_configurable_zero(STEP_THICKNESSES[i],
                                         "enforce leading zero 0._"),
                   size = STEP_TEXT_SIZE, font = TEXT_FONT, halign = "right",
                   valign = "baseline");

      // Create bridge if negative height
      if (STEP_THICKNESSES[i] < 0) {
        gap = SWATCH_ROUND * STEP_BRIDGE_GAP_RATIO;
        translate([
          -one_steparea_w + gap, SWATCH_WALL * STEP_AREA_DISTANCE,
          SWATCH_THICKNESS - (-STEP_THICKNESSES[i]) -
          STEP_TEXT_HEIGHT
        ]) cube([ one_steparea_w - gap, steparea_h, -STEP_THICKNESSES[i] ]);
      }
    }
  }
}