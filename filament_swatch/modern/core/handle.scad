include <../common/paths.scad>
include <../common/vars.scad>
include <BOSL2/std.scad>

module handle()
{
  down(BASE_THICKNESS / 2) down(P_EPSILON)
    offset_sweep(path = ROUNDED_HANDLE_PATH,
                 height = SHELF_THICKNESS + P_EPSILON,  // Only up to shelf height
                 bottom = os_circle(r = -INNER_ROUNDOVER), check_valid = false);
}