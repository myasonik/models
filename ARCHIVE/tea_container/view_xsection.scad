// view helper: true 2D section at y=0 through the closed assembly —
// check thread nesting, radial/axial clearance, rim seat
use <tea_container_004.scad>

projection(cut = true) rotate([-90, 0, 0]) assembly();
