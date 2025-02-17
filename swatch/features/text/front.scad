include <../../common/paths.scad>
include <../../common/text.scad>
include <../../common/vars.scad>

// Text sizing
top_text_ratio = 1/3;
bottom_text_ratio = (1 - top_text_ratio)/2;  // Remaining space split evenly

// Available space calculations
thickness_size = 12;
margin = .5;
text_margins = 1;
available_height = SHELF_HEIGHT - thickness_size - margin;
text_area_height = available_height - (text_margins * 2);

// Calculate text sizes
top_text_size = top_text_ratio * text_area_height;
bottom_text_size = bottom_text_ratio * text_area_height;

// Text properties
text_depth = 1.5;
text_anchor = RIGHT + TOP;  // Keep original TOP anchor

module front()
{
  attach(TOP) 
    right(SHELF_WIDTH/2) 
    left(1) 
    back(thickness_size/2) 
    fwd(margin) 
    up(P_EPSILON)
    tag("remove")
  {
    // Top text
    back(available_height/2) 
    fwd(top_text_size/2) 
      write(MATERIAL, top_text_size);
    
    // Middle text (at center)
    write(BRAND, bottom_text_size);
    
    // Bottom text
    fwd(available_height/2) 
    back(bottom_text_size/2) 
      write(COLOR, bottom_text_size);
  }
}

module write(input, text_size)
{
  text3d(input, 
         h = text_depth, 
         size = text_size * .72, 
         anchor = text_anchor, 
         $fn = 32, 
         font = TEXT_FONT,
         atype = "ycenter");
}