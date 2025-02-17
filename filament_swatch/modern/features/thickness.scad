include <../common/vars.scad>
include <../common/text.scad>

module thickness_features()
{
  DEPTHS = [ -.6, .2, .4, .6, .8, 1, 1.6 ];
  attach(TOP, BOTTOM, align = FRONT) back(1)
  {
    down(SHELF_THICKNESS)
    {
      tag("remove")
        cuboid([ 70, 10, SHELF_THICKNESS + P_EPSILON ], rounding = .5, edges = ["Z"], $fn = 32);
      // Add second cube on top, aligned to left
      left(35)
      {
        for (i = [0:len(DEPTHS) - 1]) {
          depth = DEPTHS[i];
          right(5) right(i * 10) thickness_test(depth);
        }
      }
    }
  }
}

module thickness_test(depth)
{
  thickness = abs(depth);
  label = format("{:.1f}", [thickness]);
  up(depth < 0 ? 1 : 0) tag("keep")
  {
    cube([ 10, 10, thickness ]) up(thickness / 2) text3d(
      label, h = 0.4, size = 4, font = TEXT_FONT, anchor = BOTTOM + CENTER, atype = "ycenter", $fn = 32);
  }
}