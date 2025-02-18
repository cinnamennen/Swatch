include <BOSL2/std.scad>

// Input validation for swatch parameters
MAX_TEXT_LENGTH = 30;  // Maximum length for text fields
MIN_LAYER_HEIGHT = 0.05;
MAX_LAYER_HEIGHT = 0.35;

// Validate text length and return true if valid
function validate_text(text, field_name="text", max_length=MAX_TEXT_LENGTH) =
    assert(is_string(text), str("Error: ", field_name, " must be a string"))
    assert(len(text) <= max_length, 
           str("Error: ", field_name, " length (", len(text), 
               ") exceeds maximum allowed length (", max_length, ")"))
    true;

// Validate numeric range and return true if valid
function validate_range(value, min_val, max_val, field_name="value") =
    assert(is_num(value), str("Error: ", field_name, " must be a number"))
    assert(value >= min_val && value <= max_val,
           str("Error: ", field_name, " (", value,
               ") must be between ", min_val, " and ", max_val))
    true;

// Validate all swatch parameters
module validate_swatch_params(material, brand, color, layer_height) {
    valid_material = validate_text(material, "Material", MAX_TEXT_LENGTH);
    valid_brand = validate_text(brand, "Brand", MAX_TEXT_LENGTH);
    valid_color = validate_text(color, "Color", MAX_TEXT_LENGTH);
    valid_layer = validate_range(layer_height, MIN_LAYER_HEIGHT, MAX_LAYER_HEIGHT, "Layer Height");
    
    // If any validation fails, this will have already asserted
    children();
} 