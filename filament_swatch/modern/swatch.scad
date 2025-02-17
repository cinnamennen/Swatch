include <core/base.scad>
include <features/shelf.scad>
include <features/frame.scad>
include <features/text/side.scad>
include <features/text/top.scad>

module blank(){}
module swatch()
{
  base()
  {
    frame_features();
    blank();
    // shelf_features();
  }
}

swatch();