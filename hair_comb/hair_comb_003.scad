// hair_comb_003.scad — curved plastic side comb, reproduced from photos
// See SPEC.md. All dimensions in mm.
//
// Print orientation as modeled: teeth horizontal along Y, arc in the XZ
// plane, convex face up. The comb arches over the plate on its two end
// caps. THIS PART NEEDS SUPPORT — tree support, "on build plate only",
// contact Z distance 0.2. See SPEC section 7.
//
// Geometry is built in a design frame (arc in XY, teeth along +Z) and
// rotated into the print frame at the end.

// ---- driving dimensions (SPEC section 2) -----------------------------
chord    = 69.0;   // widest point of the part, across the two ends
rise     = 12.0;   // convex outer face at the peak, above the chord line
height   = 40.0;   // spine outer edge to tooth tip
teeth    = 14;     // tooth count
shell_t  = 2.6;    // radial thickness at the spine

// ---- spine (SPEC section 6) ------------------------------------------
spine_h  = 5.0;    // tooth axis, 0 .. spine_h in the design frame
bury     = 0.5;    // how far each tooth starts below spine_h

// ---- tooth (SPEC section 5) ------------------------------------------
// Stadium cross-section: two flat faces, edges rounded at tooth_t/2.
tooth_w_root = 3.7;
tooth_w_tip  = 1.8;
tooth_t_root = 2.6;   // equal to shell_t, so the root sits flush
tooth_t_tip  = 1.6;
tip_flat     = 0.8;

// ---- derived arc (SPEC section 3) ------------------------------------
R_out    = (chord*chord/4 + rise*rise) / (2*rise);   // 55.594
R_in     = R_out - shell_t;                          // 52.994
R_mid    = R_out - shell_t/2;                        // 54.294
center_y = rise - R_out;                             // -43.594
end_r    = shell_t/2;                                // 1.300

// The spine ends in a semicircular cap centered on R_mid, so the widest
// point of the part is the cap's equator, not the sector's outer corner.
// Solve the half angle for that widest point at chord/2.
half_angle = 90 - acos((chord/2 - end_r) / R_mid);   // 37.697
span       = 2*half_angle;                           // 75.394
cell       = span / teeth;                           // 5.3853

// Lowest point of the design frame: the bottom of an end cap.
y_min = R_mid*sin(90 - half_angle) + center_y - end_r;   // -1.934

$fn     = 64;
arc_seg = 120;   // hull segments across the full span

// One spine cross-section: a full-thickness bar standing spine_h tall,
// closed by a hemisphere at the outer edge.
module puck() {
    hull() {
        translate([0, 0, end_r]) sphere(r = end_r, $fn = 48);
        translate([0, 0, spine_h - 0.01])
            cylinder(r = end_r, h = 0.01, $fn = 48);
    }
}

// The spine: a chain of hulls between consecutive pucks along the arc.
// Width is shell_t everywhere, the ends cap as semicircles of end_r, and
// the bullnose carries around the whole outer edge.
module spine() {
    for (i = [0:arc_seg-1])
        hull()
            for (k = [i, i+1]) {
                a = 90 - half_angle + span*k/arc_seg;
                translate([R_mid*cos(a), R_mid*sin(a), 0]) puck();
            }
}

// One tooth cross-section: a stadium of width w and thickness t, width
// along local X (tangential), thickness along local Y (radial). Two
// circles of diameter t, hulled, so the edges are round by construction
// and the flat face spans (w - t).
module slab(w, t, z0, z1) {
    translate([0, 0, z0])
        linear_extrude(z1 - z0)
            hull()
                for (sx = [-1, 1])
                    translate([sx*(w - t)/2, 0]) circle(d = t, $fn = 48);
}

// One tooth. It starts buried in the spine and tapers to a flat tip of
// tooth_w_tip by tooth_t_tip.
module tooth() {
    hull() {
        slab(tooth_w_root, tooth_t_root, spine_h - bury, spine_h - bury + 0.01);
        slab(tooth_w_tip,  tooth_t_tip,  height - tip_flat, height);
    }
}

// Place tooth i at the center of its angular cell.
module teeth_all() {
    for (i = [0:teeth-1]) {
        a = 90 - half_angle + cell*(i + 0.5);
        rotate([0, 0, a - 90])
            translate([0, R_mid, 0])
                tooth();
    }
}

// Design frame: arc in XY, teeth along +Z.
module comb_design() {
    translate([0, center_y, 0])
        union() {
            spine();
            teeth_all();
        }
}

// Print frame: design Z becomes Y (teeth run +Y from the spine at Y=0),
// design Y becomes Z (convex face up), and the part drops onto Z=0.
module comb() {
    translate([0, 0, -y_min])
        rotate([0, 0, 180])
            rotate([90, 0, 0])
                comb_design();
}

comb();
