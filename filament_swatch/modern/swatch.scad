/*
Enhanced implementation of the filament swatch using BOSL2 library
Starting with basic circle test features
*/

include <core/base.scad>
include <features/circles.scad>

// Wrapper modules to group children
module frame_attachments()
{
    recolor("red") attach(LEFT, CENTER) sphere(r = 4);
    recolor("blue") attach(RIGHT, CENTER) sphere(r = 4);
}

module shelf_attachments()
{
    recolor("green") attach(TOP, CENTER) sphere(r = 4);
    recolor("yellow") attach(BOTTOM, CENTER) sphere(r = 4);
}

module create_swatch()
{
    recolor("SteelBlue") base()
    {
        frame_attachments();
        shelf_attachments();
    }
}

// Only create when this is the main file
create_swatch();