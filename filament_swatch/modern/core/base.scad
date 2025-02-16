include <BOSL2/std.scad>

include <shelf.scad>
include <frame.scad>
include <handle.scad>


module base()
{
    recolor("SteelBlue")
    diff("remove")
    {
        union()
        {
            frame() if ($children > 0) children(0);
            shelf() show_anchors(s=5) if ($children > 1) children(1);
        }
         tag("remove") handle();
    }
}