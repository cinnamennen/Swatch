include <../../common/paths.scad>
include <../../common/text.scad>
include <../../common/vars.scad>

edge_anchor = RIGHT + TOP;
top_anchor = edge_anchor;
bottom_anchor = edge_anchor;
top_text_ratio = 1 / 3;
bottom_text_ratio = (1 - top_text_ratio) / 2;
thickness_size = 12;
margin = .5;
available_height = SHELF_HEIGHT - thickness_size - margin;
text_margins = 1;
available_height_for_text = available_height - (text_margins * 2);

top_text_size = top_text_ratio * available_height_for_text;
bottom_text_size = bottom_text_ratio * available_height_for_text;

text_depth = 1.5;
module front()
{
  attach(TOP) right(SHELF_WIDTH / 2) left(1) back(thickness_size / 2) fwd(margin) up(P_EPSILON)
    tag("remove")
  {
    back(available_height / 2) fwd(top_text_size / 2) write(MATERIAL, top_text_size);
    write(BRAND, bottom_text_size);
    fwd(available_height / 2) back(bottom_text_size / 2) write(COLOR, bottom_text_size);
  }
}

module write(input, text_size)
{
  text3d(input, h = text_depth, size = text_size * .72, anchor = RIGHT + TOP, $fn = 32, font = TEXT_FONT,
         atype = "ycenter");
}