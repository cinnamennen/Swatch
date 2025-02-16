include <BOSL2/std.scad>
include <vars.scad>
include <paths.scad>
module shelf()
{
    right(INNER_PATH[4].x)
    right(SHELF_WIDTH/2)
    down(BASE_THICKNESS / 2)
    up(SHELF_THICKNESS / 2)
        attachable(size=[SHELF_WIDTH, SHELF_HEIGHT, SHELF_THICKNESS - P_EPSILON]) {
            tag_scope() diff()            
                {
                    cuboid([SHELF_WIDTH, SHELF_HEIGHT, SHELF_THICKNESS - P_EPSILON], anchor=CENTER);
                    left(SHELF_WIDTH/2 + 0.5)
                        cuboid([1, SHELF_HEIGHT, SHELF_THICKNESS - P_EPSILON], anchor=CENTER);
                }
            children();
        }
    
}