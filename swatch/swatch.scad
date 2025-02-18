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
include <common/validation.scad>

// Default values for parameters
MATERIAL = "PLA";
BRAND = "Generic";
COLOR = "Natural";
LAYER_HEIGHT = 0.2;

module blank() {}

module swatch()
{
  validate_swatch_params(MATERIAL, BRAND, COLOR, LAYER_HEIGHT) {
    recolor("SteelBlue") diff("remove")
    {
      union()
      {
        frame()
        {
          overhang();
          walls();
          side();
          top();
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
}

swatch();