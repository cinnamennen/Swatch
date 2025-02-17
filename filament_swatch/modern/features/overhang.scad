include <BOSL2/std.scad>

module overhang()
{
  HEIGHT = 3;
  WIDTH = 56;
  ANGLE = 6.5;
  attach(FRONT, TOP) down(EDGE_FEATURE_DEPTH) up(P_EPSILON) zrot(ANGLE) tag("remove")
    cube([ WIDTH, HEIGHT, EDGE_FEATURE_DEPTH ]);
}