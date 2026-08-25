// hair_comb_004.scad — curved plastic side comb, reproduced from photos
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
shell_t  = 3.0;    // radial thickness at the spine

// ---- spine (SPEC section 6) ------------------------------------------
spine_h  = 5.0;    // tooth axis, 0 .. spine_h in the design frame
bury     = 0.5;    // how far each tooth starts below spine_h

// ---- tooth (SPEC section 5) ------------------------------------------
tooth_w_max  = 3.7;   // widest point of the silhouette, at 42% down
tooth_t_root = 3.0;   // radial thickness at the spine, equal to shell_t
tooth_t_tip  = 1.1;   // radial thickness at the free end
corner_r     = 0.6;   // corner radius on the tooth cross-section

// Tooth silhouette, traced off the user's red annotation of one tooth.
// s = 0 at the spine, 1 at the tip; the value is width / tooth_w_max.
// The tooth is NOT widest at the root: it swells to full width at 42%
// down and then tapers to a point.
tooth_profile = [
    [0.00, 0.88], [0.10, 0.92], [0.20, 0.95], [0.30, 0.98],
    [0.42, 1.00], [0.55, 0.97], [0.65, 0.92], [0.75, 0.81],
    [0.85, 0.63], [0.93, 0.46], [1.00, 0.32]
];

// ---- derived arc (SPEC section 3) ------------------------------------
R_out    = (chord*chord/4 + rise*rise) / (2*rise);   // 55.594
R_in     = R_out - shell_t;                          // 52.594
R_mid    = R_out - shell_t/2;                        // 54.094
center_y = rise - R_out;                             // -43.594
end_r    = shell_t/2;                                // 1.500

// The spine ends in a semicircular cap centered on R_mid, so the widest
// point of the part is the cap's equator, not the sector's outer corner.
// Solve the half angle for that widest point at chord/2.
half_angle = 90 - acos((chord/2 - end_r) / R_mid);   // 37.593
span       = 2*half_angle;                           // 75.187
cell       = span / teeth;                           // 5.3705

// Lowest point of the design frame: the bottom of an end cap.
y_min = R_mid*sin(90 - half_angle) + center_y - end_r;   // -2.232

// ---- tooth profile lookup --------------------------------------------
function seg(s, i = 0) =
    (i >= len(tooth_profile) - 2 || s <= tooth_profile[i+1][0])
        ? i : seg(s, i + 1);

function rel_w(s) =
    let (i = seg(s), a = tooth_profile[i], b = tooth_profile[i+1])
    a[1] + (s - a[0]) / (b[0] - a[0]) * (b[1] - a[1]);

function tooth_w(s) = tooth_w_max * rel_w(s);
function tooth_t(s) = tooth_t_root + s*(tooth_t_tip - tooth_t_root);

$fn      = 64;
arc_seg  = 120;   // hull segments across the full span
loft_seg = 48;    // hull segments along one tooth

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
module slab(w, t, z) {
    r = min(corner_r, (min(w, t) - 0.2)/2);
    translate([0, 0, z])
        linear_extrude(0.01)
            offset(r = r)
                square([w - 2*r, t - 2*r], center = true);
}

// One tooth: a short buried block inside the spine, then a loft along
// the silhouette to a flat tip.
module tooth() {
    hull() {
        slab(tooth_w(0), tooth_t(0), spine_h - bury);
        slab(tooth_w(0), tooth_t(0), spine_h);
    }
    for (i = [0:loft_seg-1])
        hull()
            for (k = [i, i+1]) {
                s = k/loft_seg;
                slab(tooth_w(s), tooth_t(s),
                     spine_h + s*(height - spine_h - 0.01));
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
