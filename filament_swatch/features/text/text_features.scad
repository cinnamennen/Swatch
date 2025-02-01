/*
Text-related features for filament swatch
Contains text writing and placement functions
*/

include <../../core/swatch_constants.scad>
include <text_utils.scad>



/*
Creates extruded text with consistent settings
Parameters:
    text: Text to write
    size: Font size
    font: Font to use (defaults to TEXT_FONT)
    halign: Horizontal alignment
    valign: Vertical alignment
    extrude_height: Height of extrusion
*/
module create_text(text, size, font=TEXT_FONT, halign="right", valign="baseline", extrude_height=TEXT_FONT_DEPTH)
{
    linear_extrude(height=extrude_height, convexity=10)
        text(text,
             size=size,
             font=font,
             halign=halign,
             valign=valign);
}

/*
Creates recessed text (for cutting out)
Parameters same as create_text
*/
module create_recessed_text(text, size, font=TEXT_FONT, halign="right", valign="baseline")
{
    linear_extrude(height=SWATCH_THICKNESS, convexity=10)
        text(text,
             size=size,
             font=font,
             halign=halign,
             valign=valign);
}

/*
Writes text on top edge of swatch
*/
module write_text_on_top(text_top)
{
    translate([SWATCH_WIDTH-(SWATCH_WALL+TEXT_EDGE_MARGIN), 
              SWATCH_HEIGHT, 
              SWATCH_OUTER_THICKNESS/2]) 
        rotate([-90,0,0])
            create_text(text_top,
                       size=SWATCH_OUTER_THICKNESS-TEXT_SIZE_OFFSET,
                       font=TEXT_FONT_HEAVY,
                       valign="center");
}

/*
Writes text on right face of swatch
*/
module write_text_on_side_v3(text_side1, text_side2)
{
    // Common rotation for vertical text
    vertical_text_rotation = [0,90,0];
    text_size = SWATCH_OUTER_THICKNESS-TEXT_SIZE_OFFSET;
    
    // Front text
    translate([SWATCH_WIDTH, SWATCH_WALL+TEXT_EDGE_MARGIN, SWATCH_OUTER_THICKNESS/2])
        rotate(vertical_text_rotation)
        rotate([0,0,-90])
            create_text(text_side1,
                       size=text_size,
                       font=TEXT_FONT_HEAVY,
                       valign="center",
                       extrude_height=TEXT_FONT_DEPTH*2);

    // Back text
    translate([SWATCH_WIDTH, SWATCH_HEIGHT-(SWATCH_WALL+TEXT_EDGE_MARGIN/2), SWATCH_OUTER_THICKNESS/2])
        rotate(vertical_text_rotation)
        rotate([0,0,-90])
            create_text(text_side2,
                       size=text_size,
                       font=TEXT_FONT_HEAVY,
                       halign="left",
                       valign="center",
                       extrude_height=TEXT_FONT_DEPTH*2);
}

/*
Writes main text lines on swatch
*/
module textlines(material, brand, color, textsize_upper, textsize_lower, linesep, fontname)
{   
    line_top_sep = textsize_lower * linesep;
    base_x = SWATCH_WIDTH-SWATCH_WALL;
    base_y = SWATCH_HEIGHT-SWATCH_WALL;
    
    // Material text
    translate([base_x, base_y-textsize_upper, SWATCH_THICKNESS-TEXT_RECESS_DEPTH])
        create_recessed_text(material, size=textsize_upper);

    // Brand text
    translate([base_x, base_y-textsize_upper-line_top_sep, SWATCH_THICKNESS-TEXT_RECESS_DEPTH])
        create_recessed_text(brand, size=textsize_lower);
    
    // Color text
    translate([base_x, base_y-(textsize_upper+2*line_top_sep), SWATCH_THICKNESS-TEXT_RECESS_DEPTH])
        create_recessed_text(color, size=textsize_lower);
}
