include <../common/vars.scad>
include <BOSL2/shapes3d.scad>
include <BOSL2/std.scad>

// Constants for circle tests
CIRCLE_RADIUS = 2;
CIRCLE_DIAMETER = CIRCLE_RADIUS * 2;
CIRCLE_MARGIN = 1;
CIRCLE_SPACING = (CIRCLE_DIAMETER + CIRCLE_MARGIN);
CIRCLE_TOP_MARGIN = .5;

// Create all circle test features
module geometry_features()
{
  $fn = SEGMENTS;  // Set segments for all shapes in this module
  total_width = 7 * CIRCLE_SPACING;
  start_x = -total_width / 2 + CIRCLE_RADIUS;

  attach(TOP) left(SHELF_WIDTH / 2 - CIRCLE_DIAMETER) back(SHELF_HEIGHT / 2 - CIRCLE_RADIUS)
    fwd(CIRCLE_TOP_MARGIN) up(P_EPSILON)
  {
    holes();
    dome();
    uniformity();
    bridging();
    hanging();
    slanting();
    filament();
  }
}

module holes()
{
  for (i = [0:6]) {
    tag("remove") right(i * CIRCLE_SPACING) cyl(d = CIRCLE_DIAMETER, h = BASE_THICKNESS * 2 + P_EPSILON);
  }
}

module dome()
{
  tag("keep") right(1 * CIRCLE_SPACING) down(SHELF_THICKNESS) intersection()
  {
    sphere(r = (CIRCLE_RADIUS + .01));
    up(CIRCLE_RADIUS) cube(CIRCLE_DIAMETER, center = true);
  }
}

module uniformity()
{
  tag("keep") right(2 * CIRCLE_SPACING) tag_scope("cylinder") diff("remove")
  {
    down(SHELF_THICKNESS / 2)
    {
      cyl(d = 2, h = SHELF_THICKNESS + P_EPSILON);
      tag("remove") cyl(d = 1, h = SHELF_THICKNESS + 2 * P_EPSILON);
    }

    down(SHELF_THICKNESS) up(.1) cuboid([ 1, 4, .2 ]);
    down(.1) cuboid([ 4, 1, .2 ]);
  }
}
module bridging()
{
  tag("keep") right(3 * CIRCLE_SPACING) tag_scope("cylinder") down(SHELF_THICKNESS / 2) down(.1)
    cuboid([ 2, 4, .2 ]);
}

module hanging()
{
  right(4 * CIRCLE_SPACING) tag("keep") down(SHELF_THICKNESS / 2) xrot(-90) down(CIRCLE_RADIUS / 2)
    cyl(d = 1.5, h = 3);
}

module slanting()
{
  EDGE_LENGTH = SHELF_THICKNESS - P_EPSILON * 2;
  TRIM_LENGTH = CIRCLE_DIAMETER + P_EPSILON;
  right(5 * CIRCLE_SPACING) tag("keep") tag_scope("cylinder") diff("remove")
  {
    down(SHELF_THICKNESS / 2)
    {
      xrot(-90) down(CIRCLE_RADIUS)
        prismoid(size1 = [ EDGE_LENGTH, EDGE_LENGTH ], size2 = [ 0, 0 ], h = CIRCLE_RADIUS);
      xrot(90) zrot(45) down(CIRCLE_RADIUS)
        prismoid(size1 = [ EDGE_LENGTH, EDGE_LENGTH ], size2 = [ 0, 0 ], h = CIRCLE_RADIUS);
    }
    tag("remove") up(.5) cuboid([ TRIM_LENGTH, TRIM_LENGTH, 1 ]);
    tag("remove") down(SHELF_THICKNESS + .5) cuboid([ TRIM_LENGTH, TRIM_LENGTH, 1 ]);
  }
}

module filament()
{
  TOP_WALL_THICKNESS = INNER_WALL_OFFSET + CIRCLE_TOP_MARGIN + CIRCLE_RADIUS;
  FILAMENT_DEPTH = 2 + CIRCLE_RADIUS;
  right(6 * CIRCLE_SPACING) tag("remove") down(SHELF_THICKNESS / 2)
  {
    xrot(90) down(TOP_WALL_THICKNESS / 2) cyl(d = 1.75, h = TOP_WALL_THICKNESS);
    xrot(-90) down(FILAMENT_DEPTH / 2) cyl(d = 1.75, h = FILAMENT_DEPTH);
  }
}