include <../common/paths.scad>
include <../common/vars.scad>
include <BOSL2/std.scad>

module walls_features()
{
  WALL_HEIGHT = BASE_THICKNESS + P_EPSILON;

  tag("remove") attach(FRONT, LEFT) right(INNER_WIDTH / 2) down(EDGE_FEATURE_DEPTH/2) up(P_EPSILON)
    yrot(-90) difference()
  {
    cube([ 8.6, EDGE_FEATURE_DEPTH, WALL_HEIGHT ]);
    up(1) cube([ .6, EDGE_FEATURE_DEPTH + P_EPSILON, WALL_HEIGHT + P_EPSILON ]);
    up(2.6) cube([ .8, EDGE_FEATURE_DEPTH + P_EPSILON, WALL_HEIGHT + P_EPSILON ]);
    up(4.4) cube([ 1, EDGE_FEATURE_DEPTH + P_EPSILON, WALL_HEIGHT + P_EPSILON ]);
    up(6.4) cube([ 1.2, EDGE_FEATURE_DEPTH + P_EPSILON, WALL_HEIGHT + P_EPSILON ]);
  }
}