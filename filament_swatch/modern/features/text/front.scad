include <../../common/paths.scad>
include <../../common/text.scad>
include <../../common/vars.scad>

module front()
{
  slide = (SHELF_HEIGHT / 2) - 1;
  spacing = 1.3;
  attach(RIGHT) tag("remove")
  {
    right(slide) up(P_EPSILON)
      text3d(S_HEIGHT, h = INNER_WALL_OFFSET / 2, atype = "ycenter", spin = 180, anchor = LEFT + TOP,
             size = SIDE_SIZE, font = TEXT_FONT_HEAVY, spacing = spacing, $fn = 32);

    left(slide) up(P_EPSILON)
      text3d(S_TEMP, h = INNER_WALL_OFFSET / 2, atype = "ycenter", spin = 180, anchor = RIGHT + TOP,
             size = SIDE_SIZE, font = TEXT_FONT_HEAVY, spacing = spacing, $fn = 32);
  }
}