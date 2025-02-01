include <core/base_geometry.scad>
include <core/swatch_constants.scad>
include <features/tests/advanced_tests.scad>
include <features/tests/step_tests.scad>
include <features/tests/test_patterns.scad>
include <features/text/text_features.scad>
include <features/text/text_utils.scad>

/* [Input Parameters] */
layer_height = "0.2";
temp = "230";
material = "PLA Blend";
brand = "Prusament";
color = "Oh My Gold";

// Create spaced string by joining layer_height and temp with "C"
print_settings_top =
    str(layer_height[0], " ", layer_height[1], " ", layer_height[2]);
print_settings_bottom = str(temp[0], " ", temp[1], " ", temp[2], " C");

texttop_final = space_letters(material);

$fn = 48;

textsize_upper = 5;
textsize_lower = 5;
linesep = 1.3;

module swatch() {
  // Calculate text and step area dimensions
  font_h = calc_font_height(textsize_upper, textsize_lower, linesep);
  steparea_h = calc_step_area_height(SWATCH_HEIGHT, SWATCH_WALL, font_h);

  difference() {
    // Create base with test pattern cutouts
    rounded_square_test_pattern();

    // Add text features
    write_text_on_top(texttop_final);
    write_text_on_side_v3(print_settings_bottom, print_settings_top);

    // Step pattern cutouts
    for (i = [0:len(STEP_THICKNESSES) - 1]) {
      steparea_w = calc_step_area_width(SWATCH_WIDTH, SWATCH_WALL,
                                        len(STEP_THICKNESSES), i);
      translate([
        SWATCH_WALL * 1, SWATCH_WALL * STEP_AREA_DISTANCE,
        STEP_THICKNESSES[i] < 0 ? STEP_BRIDGE_OFFSET : STEP_THICKNESSES[i]
      ]) {
        rounded_square(steparea_w, steparea_h, SWATCH_THICKNESS * 2,
                       SWATCH_ROUND);
      }
    }

    // Text area cutout for embossed text
    textlines(material, brand, color, textsize_upper, textsize_lower, linesep,
              TEXT_FONT);
  }

  // Add step test pattern with measurements
  step_test_pattern(steparea_h);

  // Add raised test features
  rounded_square_test_pattern_raised(TEST_CIRCLES);
}

swatch();