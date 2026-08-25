// hair_comb_001.scad — curved plastic side comb, reproduced from photos
// See SPEC.md. All dimensions in mm.
//
// Print orientation as modeled: spine down on the build plate, teeth up,
// tooth axis along Z. No supports. Use a brim.

// ---- driving dimensions (SPEC section 2) -----------------------------
chord    = 69.0;   // widest point of the part, across the two ends
rise     = 12.0;   // convex outer face at the peak, above the chord line
height   = 40.0;   // spine bottom to tooth tip
teeth    = 14;     // tooth count
shell_t  = 2.4;    // radial thickness at the spine

// ---- spine (SPEC section 6) ------------------------------------------
spine_h  = 5.0;    // tooth axis, 0 .. spine_h
chamfer  = 0.5;    // 45 deg chamfer on every bottom edge

// ---- tooth (SPEC section 5) ------------------------------------------
tooth_w_root = 3.7;
tooth_w_tip  = 1.8;
tooth_t_root = 2.2;
tooth_t_tip  = 1.4;
tip_flat     = 0.8;
corner_r     = 0.6;

// ---- derived arc (SPEC section 3) ------------------------------------
R_out    = (chord*chord/4 + rise*rise) / (2*rise);   // 55.594
R_in     = R_out - shell_t;                          // 53.194
R_mid    = R_out - shell_t/2;                        // 54.394
center_y = rise - R_out;                             // -43.594
end_r    = shell_t/2;                                // 1.200

// The spine ends in a semicircular cap centered on R_mid, so the widest
// point of the part is the cap's equator, not the sector's outer corner.
// Solve the half angle for that widest point at chord/2.
half_angle = 90 - acos((chord/2 - end_r) / R_mid);   // 37.762
span       = 2*half_angle;                           // 75.523
cell       = span / teeth;                           // 5.3945

$fn     = 64;
arc_seg = 120;   // hull segments across the full span

// One spine cross-section: a full-thickness puck standing spine_h tall,
// chamfered at 45 deg where it meets the build plate.
module puck() {
    hull() {
        cylinder(d = shell_t - 2*chamfer, h = 0.01, $fn = 48);
        translate([0, 0, chamfer])
            cylinder(d = shell_t, h = spine_h - chamfer, $fn = 48);
    }
}

// The spine: a chain of hulls between consecutive pucks along the arc.
// Width is shell_t everywhere, the ends cap as semicircles of end_r, and
// the chamfer carries around the whole footprint.
module spine() {
    for (i = [0:arc_seg-1])
        hull()
            for (k = [i, i+1]) {
                a = 90 - half_angle + span*k/arc_seg;
                translate([R_mid*cos(a), R_mid*sin(a), 0]) puck();
            }
}

// One tooth cross-section: a rounded rectangle, width along local X
// (tangential), thickness along local Y (radial). The corner radius
// shrinks when the section is too small to carry the full corner_r.
module slab(w, t, z0, z1) {
    r = min(corner_r, (min(w, t) - 0.2)/2);
    translate([0, 0, z0])
        linear_extrude(z1 - z0)
            offset(r = r)
                square([w - 2*r, t - 2*r], center = true);
}

// One tooth, standing from Z=0 so it merges into the spine. The bottom
// 0.5 is a 45 deg chamfer, the root section holds to spine_h, then the
// hull tapers to a flat tip of tooth_w_tip by tooth_t_tip.
module tooth() {
    hull() {
        slab(tooth_w_root - 2*chamfer, tooth_t_root - 2*chamfer, 0, 0.01);
        slab(tooth_w_root, tooth_t_root, chamfer, spine_h);
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

module comb() {
    translate([0, center_y, 0])
        union() {
            spine();
            teeth_all();
        }
}

comb();
