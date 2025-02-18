include <vars.scad>

MATERIAL = "PLA";
BRAND = "Atomic Filament";
COLOR = "Bright White";

HEIGHT = .2;
TEMP = 225;

N_HEIGHT = is_num(HEIGHT) ? HEIGHT : parse_num(HEIGHT);
N_TEMP = is_num(TEMP) ? TEMP : parse_num(TEMP);

S_HEIGHT = format("{:.1f}", [N_HEIGHT]);
S_TEMP = format("{:i}C", [N_TEMP]);

TEXT_FONT = "Overpass";                    // Default font
TEXT_FONT_HEAVY = "Overpass:style=Heavy";  // Font for emphasized text

SIDE_SIZE = BASE_THICKNESS * 1.03;