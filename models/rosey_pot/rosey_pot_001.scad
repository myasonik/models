// rosey_pot_001.scad
// Recreation of "rosey pot.step" (PotLiner) as a parametric OpenSCAD model.
// Tapered pot liner: rolled bead rim, ~10.6 deg wall draft, filleted base,
// 3 mm floor with 7 drainage holes. All dimensions in mm, taken from the STEP.

$fa = 2;
$fs = 0.5;

// ---- key dimensions (from STEP) ----
base_r        = 30.8504;   // outer radius of the flat bottom face
base_fillet_r = 5;         // fillet between bottom and outer wall
wall_start    = [35.7647, 4.0786]; // point where fillet meets the outer wall
wall_top_r    = 50;        // outer wall radius at rim height
rim_h         = 80;        // height of the rim bead centerline
bead_center_r = 51;        // radius to the rim bead center
bead_r        = 3;         // rolled rim bead (torus minor) radius
wall_in_top_r = 48.2;      // inner wall radius at the rim
floor_t       = 3;         // base thickness
floor_r       = 33.5625;   // inner floor radius
hole_r        = 3;         // drainage hole radius
hole_circle_r = 22;        // circle for the 6 outer drainage holes
n_holes       = 6;         // outer holes (plus 1 center hole)

// 2D half-profile (x = radius, y = height), revolved around Z
module profile2d() {
    union() {
        polygon(concat(
            [[0, 0], [base_r, 0]],
            // convex bottom fillet, arc center (base_r, base_fillet_r)
            [for (a = [-90:8:-10.62])
                [base_r + base_fillet_r * cos(a),
                 base_fillet_r + base_fillet_r * sin(a)]],
            [wall_start,
             [wall_top_r, rim_h],
             [49.5, rim_h + 1.5],          // tucked inside the bead
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
