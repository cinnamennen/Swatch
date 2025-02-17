include <BOSL2/std.scad>
include <core/frame.scad>
include <core/handle.scad>
include <core/shelf.scad>
include <features/geometry.scad>
include <features/overhang.scad>
include <features/text/front.scad>
include <features/text/side.scad>
include <features/text/top.scad>
include <features/thickness.scad>
include <features/walls.scad>

module blank() {}
module swatch()
{
  recolor("SteelBlue") diff("remove")
  {
    union()
    {
      frame()
      {
        // overhang();
        // walls();
        // side();
        // top();
      }
      shelf()
      {
        geometry();
        thickness();
        front();
      }
    }
    tag("remove") handle();
  }
}

swatch();