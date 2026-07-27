// view helper: intersection of body and seated lid.
// Expect ONLY the two detent bumps (intentional 0.2mm squeeze);
// anything else is a real clash.
use <tea_container_004.scad>

body_h = 72.4;
lid_top_t = 2.4;
rho = 130;  // lid seating rotation (center of free window); -D rho=<deg> to sweep

intersection() {
    body();
    translate([0, 0, body_h + lid_top_t])
        rotate([0, 0, rho])
            rotate([180, 0, 0])
                lid();
}
