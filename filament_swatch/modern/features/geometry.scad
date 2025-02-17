include <../common/vars.scad>
include <BOSL2/shapes3d.scad>
include <BOSL2/std.scad>

// Constants for circle tests
CIRCLE_RADIUS = 2;
CIRCLE_DIAMETER = CIRCLE_RADIUS * 2;
CIRCLE_MARGIN = 1;
CIRCLE_SPACING = (CIRCLE_DIAMETER + CIRCLE_MARGIN);

// Create all circle test features
module geometry_features()
{
  $fn = SEGMENTS;  // Set segments for all shapes in this module
  total_width = 7 * CIRCLE_SPACING;
  start_x = -total_width / 2 + CIRCLE_RADIUS;

  attach(TOP) left(SHELF_WIDTH / 2 - CIRCLE_DIAMETER) back(SHELF_HEIGHT / 2 - CIRCLE_RADIUS) fwd(.5)
    up(P_EPSILON)
  {
    // Create the test holes
    for (i = [0:6]) {
      tag("remove") right(i * CIRCLE_SPACING)
        cyl(d = CIRCLE_DIAMETER, h = BASE_THICKNESS * 2 + P_EPSILON);
    }

    dome();
    uniformity();
    bridging();
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