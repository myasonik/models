// rosey_pot_004.scad
// Recreation of "rosey pot.step" (PotLiner) as a parametric OpenSCAD model.
// Tapered pot liner: rolled bead rim, ~10.6 deg wall draft, filleted base,
// 3 mm floor with 7 drainage holes. All dimensions in mm, taken from the STEP.
// v002: base fillet now leads in with a 45 deg chamfer (was tangent to the
// bed, a >45 deg overhang for the first ~1.5 mm); inner rim radius bumped
// 48.2 -> 48.4 so the top wall is 1.6 mm = 4 clean 0.4 mm perimeters.
// v004: rim diameter +3 mm (wall_top_r 50 -> 51.5, bead ring OD 106 -> 109).
// v003: rim bead tucked into the wall so its first
// layers land on the wall perimeter instead of starting in mid-air. Bead
// outer diameter shrinks 108 -> 106 mm; underside still sags >45 deg but is
// anchored and hidden inside the decorative pot.

$fa = 2;
$fs = 0.5;

// ---- key dimensions (from STEP) ----
base_r        = 30.8504;   // outer radius of the flat bottom face
base_fillet_r = 5;         // fillet between bottom and outer wall
fillet_lead_a = -45;       // arc start angle; below this a 45 deg chamfer leads in
wall_start    = [35.7647, 4.0786]; // point where fillet meets the outer wall
wall_top_r    = 51.5;      // outer wall radius at rim height (v004: +1.5)
rim_h         = 80;        // height of the rim bead centerline
bead_center_r = 51.5;      // rim bead center, tucked onto the wall top
bead_r        = 3;         // rolled rim bead (torus minor) radius
wall_in_top_r = 49.9;      // inner wall radius at the rim (1.6 mm top wall)
floor_t       = 3;         // base thickness
floor_r       = 33.5625;   // inner floor radius
hole_r        = 3;         // drainage hole radius
hole_circle_r = 22;        // circle for the 6 outer drainage holes
n_holes       = 6;         // outer holes (plus 1 center hole)

// where the chamfer hands off to the fillet arc
arc_start = [base_r + base_fillet_r * cos(fillet_lead_a),
             base_fillet_r + base_fillet_r * sin(fillet_lead_a)];

// 2D half-profile (x = radius, y = height), revolved around Z
module profile2d() {
    union() {
        polygon(concat(
            [[0, 0],
             [arc_start.x - arc_start.y, 0],  // 45 deg chamfer to the arc
             arc_start],
            // convex bottom fillet, arc center (base_r, base_fillet_r)
            [for (a = [fillet_lead_a + 8:8:-10.62])
                [base_r + base_fillet_r * cos(a),
                 base_fillet_r + base_fillet_r * sin(a)]],
            [wall_start,
             [wall_top_r, rim_h],
             [wall_top_r - 0.5, rim_h + 1.5], // tucked inside the bead
             [wall_in_top_r, rim_h],
             [floor_r, floor_t],
             [0, floor_t]]
        ));
        // rolled rim bead
        translate([bead_center_r, rim_h]) circle(r = bead_r);
    }
}

difference() {
    rotate_extrude(angle = 360) profile2d();

    // 7 drainage holes: 1 center + 6 on a circle
    for (p = concat([[0, 0]],
                    [for (i = [0:n_holes-1])
                        hole_circle_r * [cos(360/n_holes*i), sin(360/n_holes*i)]]))
        translate([p.x, p.y, -1]) cylinder(r = hole_r, h = floor_t + 2);
}
