include <core/base.scad>
include <features/frame.scad>
include <features/shelf.scad>

module swatch()
{
  base()
  {
    frame_features();
    shelf_features();
  }
}

swatch();