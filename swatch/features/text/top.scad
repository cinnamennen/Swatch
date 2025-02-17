include <../../common/text.scad>
include <../../common/vars.scad>
include <../../common/paths.scad>

include <BOSL2/std.scad>

module top()
{
  attach(BACK) left(INNER_WIDTH / 2) up(P_EPSILON) tag("remove")
    text3d(MATERIAL, h = INNER_WALL_OFFSET / 2, atype = "ycenter", spin = 180, anchor = RIGHT + TOP,
           size = SIDE_SIZE, font = TEXT_FONT_HEAVY, spacing = 2, $fn = 32);
}