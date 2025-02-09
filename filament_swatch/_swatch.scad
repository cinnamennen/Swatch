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
    // Create base swatch shape
    create_base_swatch();

    // Add all cutouts
    /*
    create_all_test_features(steparea_h, "cutouts");
    create_all_text_features(
        material, brand, color, print_settings_top, print_settings_bottom,
        texttop_final, textsize_upper, textsize_lower, linesep, "cutouts");
    */
  }

  // Add all raised/additive features
  /*
  create_all_test_features(steparea_h, "additions");
  create_all_text_features(material, brand, color, print_settings_top,
                           print_settings_bottom, texttop_final, textsize_upper,
                           textsize_lower, linesep, "additions");
  */
}

swatch();