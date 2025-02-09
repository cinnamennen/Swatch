module base(anchor = CENTER, spin = 0, orient = UP)
{
    // Make the base attachable
    attachable(anchor, spin, orient, size = [ BASE_WIDTH, BASE_HEIGHT, BASE_THICKNESS ])
    {
        color_overlaps("blue")
        down(BASE_THICKNESS / 2) // Center in Z axis
        union() {
            difference()
            {
                union()
                {
                    base_shell() select($children, 0);  // First child goes to base_shell
                    shelf() select($children, 1);       // Second child goes to shelf
                }
                cutouts();
            }
        }
        children();
    }
} 