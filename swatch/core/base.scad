include <BOSL2/std.scad>
include <frame.scad>
include <handle.scad>
include <shelf.scad>

module base()
{
  recolor("SteelBlue") diff("remove")
  {
    union()
    {
      frame() if ($children > 0) children(0);
      shelf() if ($children > 1) children(1);
    }
    tag("remove") handle();
  }
}